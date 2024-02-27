import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

dotenv.config();

const ALCHEMY_API_KEY_URL = process.env.ALCHEMY_API_KEY_URL;

const PRIVATE_KEY = process.env.PRIVATE_KEY;

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: ALCHEMY_API_KEY_URL,
      //@ts-ignore
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      //@ts-ignore
      sepolia: ETHERSCAN_API_KEY,
    },
  },
};

export default config;
