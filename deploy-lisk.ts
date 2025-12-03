import { ethers } from "hardhat";

async function main() {
  console.log("🚀 Deploying COSAV on Lisk Sepolia...");

  const usdt = "0xddb2ca24fedcc2a9a1cba4e8e28e8a992736f6ce";
  const treasury = "0xbDD9DF1C4E4a0C6eC31719654f0f12D1D9c1dd4f";
  const earlyPenalty = 10;

  console.log("Constructor params:", [usdt, treasury, earlyPenalty]);

  const [deployer] = await ethers.getSigners();

  const nonce = await deployer.getTransactionCount("latest");
  console.log("Using nonce:", nonce);

  const CommitSaving = await ethers.getContractFactory("CommitSaving");

  const gasPrice = ethers.utils.parseUnits("0.1", "gwei"); // ethers v5

  const contract = await CommitSaving.deploy(
    usdt,
    treasury,
    earlyPenalty,
    {
      nonce: nonce,
      gasPrice: gasPrice
    }
  );

  console.log("📡 TX hash:", contract.deployTransaction.hash);

  await contract.deployed();

  console.log("✔️ CONTRACT deployed at:", contract.address);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
