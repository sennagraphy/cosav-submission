import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    liskSepolia: {
      url: "https://rpc.sepolia-api.lisk.com",
      chainId: 4202,
      accounts: [
        "0xe197a2140a4aeaaad73cd5beb5ee96d4b541e0882aec7f350c3e9ce95e94f415"
      ],
      gasPrice: 100000000,
      maxPriorityFeePerGas: 0,
    },
  },
  sourcify: {
    enabled: true,
  }
};

export default config;
