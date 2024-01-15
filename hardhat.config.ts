import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      // klaytn currently compatible with london
      // https://docs.klaytn.foundation/docs/build/smart-contracts/porting-ethereum-contract/#solidity-support-
      evmVersion: "london",
      optimizer: {
        // recommended when testing and debugging
        // https://hardhat.org/hardhat-network/docs/reference#solidity-optimizer-support
        // enabled: true,
      },
    },
  },
};

export default config;
