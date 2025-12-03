COSAV — Commitment Saving Protocol (Lisk Sepolia)
Project: COSAV (Commitment Saving Protocol)
Author: Sennagraphy (@sennagraphy)
Network: Lisk Sepolia (chainId 4202)
Latest Contract Deployment:

CommitSaving v3 — 0xEc06216709cA6869D07ED50379227149601729E5 (latest)

🧩 One-liner

COSAV is a simple but powerful commitment-saving smart contract where users deposit USDT, must check-in within defined time windows, and pay penalties when they miss — designed for habit-building, discipline, and gamified finance.

⭐ Why COSAV Matters

Traditional saving apps fail because they rely on willpower.
COSAV implements behavioral economics on-chain:

Commitment device → users lock funds upfront.

Daily check-ins → consistent habit loop.

Penalties for skipping → behavioral reinforcement.

Transparent & trustless → enforced fully by smart contract.

This unlocks new use cases:

Saving challenges

Fitness or bootcamp accountability

Community saving pools

Productivity & discipline systems

DAO gamified personal finance tools

Lightweight, audited patterns (OpenZeppelin), and fully transparent.

🔥 Core Features
User Flow

startCommit(dailyAmount, durationDays)
Pulls total deposit via SafeERC20, requires pre-approval.

checkIn()
User must check in within allowed time window
→ Minimum: 12 hours
→ Maximum: 48 hours

paySkipPenalty()
For users who miss check-in — pay penalty and continue.

earlyWithdraw()
Cancel commitment early; remaining balance returned minus fee (default 10%).

Admin Features

Update penalty percentage

Update check-in windows

Link Badge NFT contract (optional gamification)

Treasury address for penalty distribution

Security

Built with OpenZeppelin

Uses SafeERC20 for safe token interactions

AccessControl for admin isolation

Optimizer enabled

Designed to be audit-friendly

📦 Contracts Overview
/contracts
  ├── CommitSaving.sol    # main contract
  ├── BadgeNFT.sol        # optional gamification
  └── COSAV.sol           # previous iteration / backup

Important Files

contracts/CommitSaving.sol — Core protocol

contracts/BadgeNFT.sol — Optional badge minting

contracts/COSAV.sol — Earlier version kept for reference

scripts/deploy-lisk.ts — Deployment script

hardhat.config.ts — Lisk Sepolia config

artifacts/ — All compiled build data (needed for verification)

README.md — You are here

🛠️ Running Locally
Prerequisites

Node.js v20 (recommended)

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


You will see output including:

TX hash

Contract address

Nonce & gas

Open Hardhat console
npx hardhat console --network liskSepolia


Example:

const c = await ethers.getContractAt("CommitSaving", "0x705D22b68f90d8C2E7EA54CBe2931C1d6C63c49Fb");
await c.checkIn();

🔍 Verification Notes

Sourcify verification is enabled.
However, Lisk Sepolia’s explorer endpoints may return 500 / DNS errors occasionally.

To support manual verification:

Include in repo:

/artifacts/**

/artifacts/build-info/**

hardhat.config.ts

All source contracts

Deployment logs (screenshots recommended)

If verification fails:

Provide ABI from artifacts/contracts/CommitSaving.sol/*.json

Provide deployed bytecode

Provide constructor arguments

🧪 Example Interactions (ethers.js)
const c = await ethers.getContractAt("CommitSaving", "<DEPLOYED_ADDRESS>");

await c.startCommit(
  ethers.utils.parseUnits("10", 6), // daily USDT
  30                                // 30 days challenge
);

await c.checkIn();
await c.paySkipPenalty();
await c.earlyWithdraw();

🔒 Security Notes

Admin role is DEFAULT_ADMIN_ROLE → must be protected

Contract uses SafeERC20 to prevent failures

No reentrancy functions (commit flow mainly pull-based)

For production usage:

Add reentrancy guards

Add circuit breakers

Expand event coverage

🗂️ Recommended Repository Structure
submission/
├── artifacts/
├── contracts/
├── scripts/
│     └── deploy-lisk.ts
├── hardhat.config.ts
└── README.md


Optional:

README-screenshots/
LICENSE

📝 What We Submit to Devfolio
Short Description :

Commitment-saving smart contract on Lisk. Users deposit USDT, check in daily, and pay penalties when skipping—designed for habit-building and gamified personal finance.

Long Description :

COSAV is a commitment-saving protocol built on Lisk Sepolia. It combines behavioral economics with transparent smart contract rules: users deposit USDT upfront, must check in within defined time windows, and pay penalties when skipping. It’s suitable for saving challenges, productivity apps, bootcamp accountability, and community gamified finance. Built using OpenZeppelin, SafeERC20, and AccessControl.

Contract Address:

0x705D22b68f90d8C2E7EA54CBe2931C1d6C63c49Fb

Attachments Recommended

Deployment screenshots

Explorer screenshot (contract page)

artifacts.zip (optional)

📜 License

MIT License

📬 Contact

Sennagraphy (sennagraphy)
Email: sennagraphy@gmail.com

X/Twitter: @sennagraphy

📅 Changelog

2025-12-03 — CommitSaving deployed to Lisk Sepolia (v2):
0x705D22b68f90d8C2E7EA54CBe2931C1d6C63c49Fb
