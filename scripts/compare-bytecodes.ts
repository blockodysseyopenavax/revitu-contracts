import fs from "fs";

const hardhatArtifact = JSON.parse(
  fs.readFileSync("artifacts/contracts/Revitu.sol/Revitu.json").toString(),
);
const foundryArtifact = JSON.parse(
  fs.readFileSync("out/Revitu.sol/Revitu.json").toString(),
);
console.log(Object.keys(foundryArtifact.bytecode));

// compare and check if bytecodes are almost same
// only bytecode_hash differs
// until contracts/test/* contracts are added
console.log(
  hardhatArtifact.bytecode.length,
  foundryArtifact.bytecode.object.length,
);
console.log(
  hardhatArtifact.deployedBytecode.length,
  foundryArtifact.deployedBytecode.object.length,
);
