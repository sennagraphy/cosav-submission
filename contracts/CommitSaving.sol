// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
  CommitSaving - simple daily commitment flow
  - User calls startCommit(dailyAmount, durationDays)
    -> contract pulls total = dailyAmount * durationDays (user must approve first)
  - User must call checkIn() every "minInterval" (12h) and before "maxInterval" (48h)
    -> progress increments
  - If user misses > maxInterval, they must call paySkipPenalty() (5%) to resume
  - User can earlyWithdraw() paying earlyPenaltyPercent (10%) on remaining amount
  - When completedDays >= duration => finalize() gives user remaining funds back and mints badge
  - Admin can set badgeContract (needs to be granted MINTER_ROLE in BadgeNFT)
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IBadge {
  function mintBadge(address to, string calldata tokenURI_) external;
}

contract CommitSaving is AccessControl {
  using SafeERC20 for IERC20;

  bytes32 public constant DEFAULT_ADMIN = DEFAULT_ADMIN_ROLE;

  // token used for commits (e.g., USDT)
  IERC20 public usdt;

  // treasury receives penalties
  address public treasury;

  // percents expressed in whole numbers (e.g., 5 means 5%)
  uint256 public skipPenaltyPercent = 5;
  uint256 public earlyPenaltyPercent = 10;

  // time windows (seconds)
  uint256 public minInterval = 12 * 3600; // 12 hours
  uint256 public maxInterval = 48 * 3600; // 48 hours

  // badge contract address (set by admin)
  address public badgeContract;

  // Commitment struct per user
  struct Commitment {
    uint256 totalAmount;     // total tokens deposited for the commitment (in token smallest unit)
    uint256 dailyAmount;     // daily expected amount
    uint256 durationDays;    // total days to complete
    uint256 startTimestamp;  // start time of commitment
    uint256 lastCheckin;     // timestamp of last successful check-in
    uint256 completedDays;   // how many days checked in successfully
    bool active;             // active/inactive
  }

  mapping(address => Commitment) public commitments;

  // Events
  event CommitStarted(address indexed user, uint256 totalAmount, uint256 dailyAmount, uint256 durationDays);
  event CheckedIn(address indexed user, uint256 completedDays);
  event SkipPenaltyPaid(address indexed user, uint256 penaltyAmount);
  event EarlyWithdrawn(address indexed user, uint256 amountAfterPenalty);
  event Finalized(address indexed user, uint256 returnedAmount);
  event BadgeContractSet(address indexed admin, address badge);

  constructor(address usdtAddress, address treasuryAddress, uint256 _earlyPenaltyPercent) {
    require(usdtAddress != address(0), "invalid usdt");
    require(treasuryAddress != address(0), "invalid treasury");
    usdt = IERC20(usdtAddress);
    treasury = treasuryAddress;
    earlyPenaltyPercent = _earlyPenaltyPercent;
    _grantRole(DEFAULT_ADMIN, msg.sender);
  }

  // ======= ADMIN =======
  function setBadgeContract(address _badge) external onlyRole(DEFAULT_ADMIN) {
    badgeContract = _badge;
    emit BadgeContractSet(msg.sender, _badge);
  }

  function setPenaltyPercents(uint256 _skipPercent, uint256 _earlyPercent) external onlyRole(DEFAULT_ADMIN) {
    skipPenaltyPercent = _skipPercent;
    earlyPenaltyPercent = _earlyPercent;
  }

  function setTimeWindows(uint256 _minIntervalSec, uint256 _maxIntervalSec) external onlyRole(DEFAULT_ADMIN) {
    require(_minIntervalSec > 0 && _maxIntervalSec > _minIntervalSec, "invalid windows");
    minInterval = _minIntervalSec;
    maxInterval = _maxIntervalSec;
  }

  // ======= USER FLOW =======

  /// @notice start a new commitment
  /// @param dailyAmount amount expected per day (in token smallest unit)
  /// @param durationDays number of days to commit
  function startCommit(uint256 dailyAmount, uint256 durationDays) external {
    require(dailyAmount > 0, "dailyAmount > 0");
    require(durationDays > 0, "durationDays > 0");

    Commitment storage c = commitments[msg.sender];
    require(!c.active, "active commit exists");

    uint256 total = dailyAmount * durationDays;
    require(total / durationDays == dailyAmount, "overflow"); // simple sanity

    // Transfer tokens from user to contract
    usdt.safeTransferFrom(msg.sender, address(this), total);

    // Initialize commitment
    commitments[msg.sender] = Commitment({
      totalAmount: total,
      dailyAmount: dailyAmount,
      durationDays: durationDays,
      startTimestamp: block.timestamp,
      lastCheckin: block.timestamp,
      completedDays: 0,
      active: true
    });

    emit CommitStarted(msg.sender, total, dailyAmount, durationDays);
  }

  /// @notice call to register today's check-in
  function checkIn() external {
    Commitment storage c = commitments[msg.sender];
    require(c.active, "no active commit");

    // must wait at least minInterval from last check-in
    require(block.timestamp >= c.lastCheckin + minInterval, "too early for check-in");

    // must check-in before maxInterval passes
    require(block.timestamp <= c.lastCheckin + maxInterval, "missed window - please pay skip penalty to continue");

    // increment progress
    c.lastCheckin = block.timestamp;
    c.completedDays += 1;

    // If completed all days => finalize
    if (c.completedDays >= c.durationDays) {
      _finalizeCommit(msg.sender);
    } else {
      emit CheckedIn(msg.sender, c.completedDays);
    }
  }

  /// @notice user pays skip penalty when they missed > maxInterval to resume
  /// penalty = (remaining * skipPenaltyPercent) / 100
  function paySkipPenalty() external {
    Commitment storage c = commitments[msg.sender];
    require(c.active, "no active commit");

    // must be overdue
    require(block.timestamp > c.lastCheckin + maxInterval, "not overdue yet");

    // compute remaining (not yet earned)
    uint256 earned = c.dailyAmount * c.completedDays;
    uint256 remaining = 0;
    if (c.totalAmount > earned) remaining = c.totalAmount - earned;

    require(remaining > 0, "nothing remaining");

    uint256 penalty = (remaining * skipPenaltyPercent) / 100;
    // transfer penalty to treasury
    usdt.safeTransfer(treasury, penalty);

    // shrink the totalAmount by penalty so user's remaining reduces
    c.totalAmount = c.totalAmount - penalty;

    // set lastCheckin to now, user still must call checkIn after paying (or we optionally allow immediate check-in)
    c.lastCheckin = block.timestamp;

    emit SkipPenaltyPaid(msg.sender, penalty);
  }

  /// @notice early withdraw - user cancels early and receives remaining - earlyPenaltyPercent
  function earlyWithdraw() external {
    Commitment storage c = commitments[msg.sender];
    require(c.active, "no active commit");

    // compute earned so far
    uint256 earned = c.dailyAmount * c.completedDays;
    uint256 remaining = 0;
    if (c.totalAmount > earned) remaining = c.totalAmount - earned;

    // apply early penalty on remaining
    uint256 penalty = (remaining * earlyPenaltyPercent) / 100;
    uint256 payout = remaining - penalty;

    // mark inactive
    c.active = false;
    c.totalAmount = 0;
    c.dailyAmount = 0;
    c.durationDays = 0;
    c.startTimestamp = 0;
    c.lastCheckin = 0;
    c.completedDays = 0;

    // send penalty to treasury and payout to user
    if (penalty > 0) usdt.safeTransfer(treasury, penalty);
    if (payout > 0) usdt.safeTransfer(msg.sender, payout);

    emit EarlyWithdrawn(msg.sender, payout);
  }

  // Internal finalize: return remaining tokens to user and mint badge if possible
  function _finalizeCommit(address user) internal {
    Commitment storage c = commitments[user];
    require(c.active, "not active");
    // compute earned (should be total minus penalties already applied)
    uint256 earned = c.dailyAmount * c.completedDays;
    uint256 toReturn = 0;
    if (c.totalAmount > earned) {
      toReturn = c.totalAmount - earned;
    }
    // clean commitment
    c.active = false;
    c.totalAmount = 0;
    c.dailyAmount = 0;
    c.durationDays = 0;
    c.startTimestamp = 0;
    c.lastCheckin = 0;
    c.completedDays = 0;

    // return funds
    if (toReturn > 0) usdt.safeTransfer(user, toReturn);

    // mint badge (if badgeContract set)
    if (badgeContract != address(0)) {
      // call mintBadge on the badge contract (CommitSaving should be granted MINTER_ROLE on BadgeNFT)
      IBadge(badgeContract).mintBadge(user, "");
    }

    emit Finalized(user, toReturn);
  }

  /// @notice helper: read user's commitment
  function getCommitment(address user) external view returns (Commitment memory) {
    return commitments[user];
  }
}
