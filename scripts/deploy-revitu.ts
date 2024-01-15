import { ethers, upgrades } from "hardhat";

const DEFAULT_ADMIN_ROLE = ethers.zeroPadBytes("0x", 32);
const UPGRADER_ROLE = ethers.id("UPGRADER_ROLE");

async function main() {
  const [deployer] = await ethers.getSigners();
  const Revitu = await ethers.getContractFactory("Revitu", deployer);
  const revitu = await upgrades.deployProxy(
    Revitu,
    [
      deployer.address, // defaultAdmin
      deployer.address, // minter
      deployer.address, // upgrader
      "", // baseTokenURI
    ],
    { kind: "uups" },
  );

  console.log("Revitu (proxy) deployed at", await revitu.getAddress());
  console.log(
    `(impl at ${await upgrades.erc1967.getImplementationAddress(
      await revitu.getAddress(),
    )})`,
  );
}

// recommended pattern by hardhat docs
// https://hardhat.org/hardhat-runner/docs/guides/deploying#deploying-your-contracts
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
