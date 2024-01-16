# Revitu Contracts

[Revitu](./contracts/Revitu.sol) is an ERC721 / KIP17 compliant NFT contract.

## Features

- UUPS upgradeable
- ERC721Enumerable, ERC721URIStorage
- Mintable with tokenURI
- Auto incrementing tokenId (from 0, step 1)
- MINTER_ROLE support
- KIP17 support
- Modifiable baseTokenURI
- Token-wise locking

## Test

```Bash
[REPORT_GAS=true] npx hardhat test
```

## Deploy

Set `REVITU_DEPLOYER_PRIVATE_KEY` in `.env` then run

```Bash
npx hardhat run scripts/deploy-revitu.ts [--network <networkName>]
```

## Upgrade

Set `REVITU_DEPLOYER_PRIVATE_KEY` and `REVITU_ADDRESS` in `.env` then run

```Bash
npx hardhat run scripts/upgrade-revitu.ts [--network <networkName>]
```