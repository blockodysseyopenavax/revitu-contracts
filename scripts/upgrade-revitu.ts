import { ethers, upgrades } from "hardhat";

const DEFAULT_ADMIN_ROLE = ethers.zeroPadBytes("0x", 32);
const UPGRADER_ROLE = ethers.id("UPGRADER_ROLE");

async function main() {
  const revituAddress = ethers.getAddress(process.env.REVITU_ADDRESS || "");

  const [upgrader] = await ethers.getSigners();
  const Revitu = await ethers.getContractFactory("Revitu", upgrader);
  const revitu = await upgrades.upgradeProxy(revituAddress, Revitu, {
    kind: "uups",
  });
  await revitu.waitForDeployment();

  console.log("Revitu", revituAddress, "upgraded");
  console.log(
    `(impl at ${await upgrades.erc1967.getImplementationAddress(
      revituAddress,
    )})`,
  );
}

// recommended pattern by hardhat docs
// https://hardhat.org/hardhat-runner/docs/guides/deploying#deploying-your-contracts
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
