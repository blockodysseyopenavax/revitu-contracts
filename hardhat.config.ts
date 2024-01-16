import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "dotenv/config";

const deployer = process.env.REVITU_DEPLOYER_PRIVATE_KEY || "";

const config: HardhatUserConfig = {
  networks: {
    baobab: {
      url: "https://public-en-baobab.klaytn.net",
      chainId: 1001,
      accounts: [deployer],
    },
    cypress: {
      url: "https://public-en-cypress.klaytn.net",
      chainId: 8217,
      accounts: [deployer],
    },
  },
  solidity: {
    version: "0.8.19",
    settings: {
      // klaytn currently compatible with london
      // https://docs.klaytn.foundation/docs/build/smart-contracts/porting-ethereum-contract/#solidity-support-
      evmVersion: "london",
      optimizer: {
        // recommended when testing and debugging
        // https://hardhat.org/hardhat-network/docs/reference#solidity-optimizer-support
        // enabled: false, // default: false

        enabled: true,
      },
    },
  },
};

export default config;
