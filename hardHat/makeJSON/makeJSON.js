const fs = require("fs");
const path = require("path");
const basePath = __dirname;

const factoryABI =
  require("../artifacts/contracts/NFTContract/LiteraryFactory.sol/LiteraryFactory.json").abi;
const tokenABI =
  require("../artifacts/contracts/Token/Token.sol/Token.json").abi;
const workABI =
  require("../artifacts/contracts/NFTContract/LiteraryWork.sol/LiteraryWork.json").abi;

const makeFactoryJSON = async (address) => {
  fs.writeFileSync(
    path.join(
      basePath,
      "../../client/src/components/contracts/JSON/factory.json"
    ),
    JSON.stringify({ abi: factoryABI, address: address })
  );
};

const makeTokenJSON = async (address) => {
  fs.writeFileSync(
    path.join(
      basePath,
      "../../client/src/components/contracts/JSON/token.json"
    ),
    JSON.stringify({ abi: tokenABI, address: address })
  );
};

const makeWorkJSON = async () => {
  fs.writeFileSync(
    path.join(basePath, "../../client/src/components/contracts/JSON/work.json"),
    JSON.stringify({ abi: workABI })
  );
};

module.exports = {
  makeFactoryJSON,
  makeTokenJSON,
  makeWorkJSON,
};
