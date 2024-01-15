import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
// // use network helpers re-exported by toolbox
// // https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-toolbox#network-helpers
// import helpers from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("Revitu", function () {
  const DEFAULT_ADMIN_ROLE = ethers.zeroPadBytes("0x", 32);
  const UPGRADER_ROLE = ethers.id("UPGRADER_ROLE");
  const MINTER_ROLE = ethers.id("MINTER_ROLE");

  async function deployRevituFixture() {
    const [deployer, user] = await ethers.getSigners();
    const Revitu = await ethers.getContractFactory("Revitu", deployer);
    const revitu = await upgrades.deployProxy(Revitu, [
      deployer.address, // defaultAdmin
      deployer.address, // minter
      deployer.address, // upgrader
      "", // baseTokenURI
    ]);
    await revitu.waitForDeployment();
    const revituAddress = await revitu.getAddress();
    return {
      Revitu,
      revitu,
      revituAddress,
      deployer,
      user,
    };
  }

  it("Should be initialized successfully", async function () {
    const { Revitu, revitu, deployer, user } =
      await loadFixture(deployRevituFixture);
    expect(await revitu.name()).to.equal("Blockodyssey Revitu NFT");
    expect(await revitu.symbol()).to.equal("REVITU");
    expect(await revitu.hasRole(DEFAULT_ADMIN_ROLE, deployer.address)).to.be
      .true;
    expect(await revitu.hasRole(MINTER_ROLE, deployer.address)).to.be.true;
    expect(await revitu.hasRole(UPGRADER_ROLE, deployer.address)).to.be.true;
    expect(await revitu.totalSupply()).to.equal(0);
    await expect(revitu.ownerOf(0)).to.be.reverted;
    await expect(revitu.tokenURI(0)).to.be.reverted;
    expect(await revitu.getBaseTokenURI()).to.equal("");
  });

  it("Should mint a nft", async function () {
    const { Revitu, revitu, deployer, user } =
      await loadFixture(deployRevituFixture);
    const uri = "https://blockodyssey.io";
    const tokenId = 0; // id starts from 0
    await expect(revitu.safeMint(user.address, uri))
      .to.emit(revitu, "Transfer")
      .withArgs(ethers.ZeroAddress, user.address, tokenId);
    expect(await revitu.totalSupply()).to.equal(1);
    expect(await revitu.ownerOf(tokenId)).to.equal(user.address);
    expect(await revitu.tokenURI(tokenId)).to.equal(uri);
  });

  it("Should handle IERC721Receiver", async function () {
    const { Revitu, revitu, deployer, user } =
      await loadFixture(deployRevituFixture);
    const factory = await ethers.getContractFactory("ERC721Holder");
    const holder = await factory.deploy();
    await holder.waitForDeployment();

    await expect(
      revitu.safeMint(await holder.getAddress(), "https://blockodyssey.io"),
    )
      .to.emit(revitu, "Transfer")
      .withArgs(ethers.ZeroAddress, await holder.getAddress(), 0);
  });

  it("Should handle IKIP17Receiver", async function () {
    const { Revitu, revitu, deployer, user } =
      await loadFixture(deployRevituFixture);
    const factory = await ethers.getContractFactory("KIP17Holder");
    const holder = await factory.deploy();
    await holder.waitForDeployment();

    await expect(
      revitu.safeMint(await holder.getAddress(), "https://blockodyssey.io"),
    )
      .to.emit(revitu, "Transfer")
      .withArgs(ethers.ZeroAddress, await holder.getAddress(), 0);
  });

  it("Should manage baseTokenURI", async function () {
    const { Revitu, revitu, deployer, user } =
      await loadFixture(deployRevituFixture);

    const baseTokenURI = "https://blockodyssey.io/tokens/";
    await revitu.setBaseTokenURI(baseTokenURI);
    expect(await revitu.getBaseTokenURI()).to.equal(baseTokenURI);

    await revitu.safeMint(user.address, "0");
    expect(await revitu.tokenURI(0)).to.equal(
      "https://blockodyssey.io/tokens/0",
    );

    // do not mix baseTokenURI & full tokenURI
    await revitu.safeMint(user.address, "https://txodyssey.io/tokens/1");
    expect(await revitu.tokenURI(1)).to.equal(
      "https://blockodyssey.io/tokens/https://txodyssey.io/tokens/1",
    );
  });

  it("Should manage token locks", async function () {
    const { Revitu, revitu, revituAddress, deployer, user } =
      await loadFixture(deployRevituFixture);

    await revitu.safeMint(user.address, "0");
    expect(await revitu.isLocked(0)).to.be.false;

    const revituForUser = await ethers.getContractAt(
      "Revitu",
      revituAddress,
      user,
    );
    // token transfer should be reverted if locked
    await revitu.lockToken(0);
    expect(await revitu.isLocked(0)).to.be.true;
    await expect(revituForUser.transferFrom(user.address, deployer.address, 0))
      .to.be.reverted;
    await expect(
      revituForUser["safeTransferFrom(address,address,uint256)"](
        user.address,
        deployer.address,
        0,
      ),
    ).to.be.reverted;
    await expect(
      revituForUser["safeTransferFrom(address,address,uint256,bytes)"](
        user.address,
        deployer.address,
        0,
        "0x",
      ),
    ).to.be.reverted;
    // token transfer should be done if unlocked
    await revitu.unlockToken(0);
    expect(await revitu.isLocked(0)).to.be.false;
    await revituForUser.transferFrom(user.address, deployer.address, 0);
  });
});
