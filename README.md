COSAV — Commitment Saving Protocol (Lisk Sepolia)

Project: COSAV (Commitment Saving Protocol)
Author: Sennagraphy (@sennagraphy)
Network: Lisk Sepolia (chainId 4202)
Latest Deployment:
CommitSaving v3 — 0xEc06216709cA6869D07ED50379227149601729E5

🧩 One-liner
COSAV is a commitment-saving smart contract where users deposit USDT, must check in within specific time windows, and pay penalties when they miss — designed for habit-building, discipline, and gamified finance.

⭐ Why COSAV Matters
Traditional saving apps fail because they rely on willpower. COSAV instead uses behavioral economics on-chain:

Commitment device → users lock funds upfront
Daily check-ins → consistent habit loop
Penalties for skipping → behavioral reinforcement
Transparent & trustless → enforced fully by smart contract

Use Cases
Saving challenges
Fitness / bootcamp accountability
Community pooled savings
Productivity & discipline systems
DAO gamified finance tools
COSAV uses lightweight, audited OpenZeppelin patterns and is fully transparent.

🔥 Core Features
User Flow
startCommit(dailyAmount, durationDays)
→ Pulls total deposit using SafeERC20 (requires USDT approval)

checkIn()
→ User must check in within time window:

Minimum: 12 hours
Maximum: 48 hours

paySkipPenalty()
→ Pay penalty if user misses check-in

earlyWithdraw()
→ Withdraw early; remaining balance returned minus fee (default 10%)

Admin Features
Update penalty percentage
Update check-in windows
Link BadgeNFT contract
Update treasury address

Security
OpenZeppelin-based
SafeERC20
AccessControl
Optimizer enabled
Audit-friendly architecture

📦 Contracts Overview
/contracts
  ├── CommitSaving.sol    # main contract
  ├── BadgeNFT.sol        # optional NFT gamification
  └── COSAV.sol           # older version (reference)

Important Files
contracts/CommitSaving.sol — Core protocol
scripts/deploy-lisk.ts — Deployment script
hardhat.config.ts — Network config
artifacts/ — compiled build (for verification)
README.md — documentation

🛠️ Running Locally
Prerequisites
Node.js v20
npm or yarn
Hardhat

Install
npm install
# or
yarn

Compile
npx hardhat compile

Deploy to Lisk Sepolia
npx hardhat run scripts/deploy-lisk.ts --network liskSepolia


The output will include:
TX hash
Contract address
Nonce & gas usage

Hardhat Console
npx hardhat console --network liskSepolia

🔍 Verification Notes

Sourcify auto-verification is enabled.
Lisk Sepolia explorer sometimes returns 500/DNS errors.

To support manual verification, include:
/artifacts/**
/artifacts/build-info/**
hardhat.config.ts
All source contracts
Deployment screenshots (recommended)

If verification fails, provide:
ABI
Deployed bytecode
Constructor arguments

🧪 Example Interactions (ethers.js)
const c = await ethers.getContractAt("CommitSaving", "<DEPLOYED_ADDRESS>");

await c.startCommit(
  ethers.utils.parseUnits("10", 6), // daily USDT
  30                                // 30 days
);

await c.checkIn();
await c.paySkipPenalty();
await c.earlyWithdraw();

🔒 Security Notes
Admin role = DEFAULT_ADMIN_ROLE → must be secured
SafeERC20 protects token transfers
Commit flow is pull-based → low reentrancy risk

For production:
Add reentrancy guards
Add circuit breakers
Add more events

🗂️ Recommended Repository Structure
submission/
├── artifacts/
├── contracts/
├── scripts/
│     └── deploy-lisk.ts
├── screenshots/
├── hardhat.config.ts
└── README.md


Optional:
LICENSE
Additional documentation

📝 Devfolio Submission Info
Short Description
Commitment-saving smart contract on Lisk: users deposit USDT, check in daily, and pay penalties when skipping. Designed for habit-building and gamified personal finance.

Long Description
COSAV is a commitment-saving protocol built on Lisk Sepolia. Users deposit USDT upfront, must check in within defined time windows, and pay penalties when they skip. COSAV applies behavioral economics principles to create real financial discipline. Use cases include saving challenges, productivity apps, bootcamp accountability, and gamified finance communities. Built using OpenZeppelin, SafeERC20, and AccessControl.

Latest Contract Address
0xEc06216709cA6869D07ED50379227149601729E5

Recommended Attachments
Deployment screenshots
Explorer page screenshots
artifacts.zip (optional)

📜 License
MIT License

📬 Contact
Sennagraphy
Email: sennagraphy@gmail.com
X/Twitter: @sennagraphy

📅 Changelog
2025-12-03 — CommitSaving deployed on Lisk Sepolia (v3)
Address: 0xEc06216709cA6869D07ED50379227149601729E5
