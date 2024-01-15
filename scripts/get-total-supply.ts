import { ethers } from "hardhat";

async function main() {
  const revituAddress = ethers.getAddress(process.env.REVITU_ADDRESS || "");

  const revitu = await ethers.getContractAt("Revitu", revituAddress);
  console.log("Revitu total supply:", await revitu.totalSupply());
}
main();
