// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    COSAV – Commitment Saving Contract (Basic Version)

    Features (basic):
    - Users can start a commitment saving using USDT
    - System records total deposits & start time
    - Users may withdraw after 30 days
    - Early withdrawal triggers a 10% penalty
*/

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
}

contract COSAV {
    IERC20 public usdt;  // Address of USDT token contract
    uint256 public constant LOCK_DAYS = 30;
    uint256 public constant EARLY_PENALTY = 10; // 10%

    struct Saving {
        uint256 totalDeposited;
        uint256 startTime;
        bool active;
    }

    mapping(address => Saving) public savings;

    constructor(address _usdt) {
        usdt = IERC20(_usdt);
    }

    // Start a new saving commitment (User must approve USDT first)
    function startSaving(uint256 amount) external {
        require(!savings[msg.sender].active, "Saving already active");
        require(amount >= 1e6, "Minimum is 1 USDT"); // USDT uses 6 decimals

        usdt.transferFrom(msg.sender, address(this), amount);

        savings[msg.sender] = Saving({
            totalDeposited: amount,
            startTime: block.timestamp,
            active: true
        });
    }

    // Add daily deposit
    function deposit(uint256 amount) external {
        require(savings[msg.sender].active, "No active saving");
        require(amount >= 1e6, "Minimum is 1 USDT");

        usdt.transferFrom(msg.sender, address(this), amount);
        savings[msg.sender].totalDeposited += amount;
    }

    // Withdraw funds (with penalty if before 30 days)
    function withdraw() external {
        Saving storage s = savings[msg.sender];
        require(s.active, "No active saving");

        uint256 amount = s.totalDeposited;
        uint256 timePassed = block.timestamp - s.startTime;

        s.active = false;

        // Apply penalty if withdrawing before 30 days
        if (timePassed < LOCK_DAYS * 1 days) {
            uint256 penalty = (amount * EARLY_PENALTY) / 100;
            amount -= penalty;
        }

        usdt.transfer(msg.sender, amount);
    }
}
