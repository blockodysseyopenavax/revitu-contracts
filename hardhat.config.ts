import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      // klaytn currently compatible with london
      // https://docs.klaytn.foundation/docs/build/smart-contracts/porting-ethereum-contract/#solidity-support-
      evmVersion: "london",
    },
  },
};

export default config;
