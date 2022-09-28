const hre = require("hardhat");

const {
  makeFactoryJSON,
  makeWorkJSON,
  makeTokenJSON,
} = require("../makeJSON/makeJSON");

const categoryList = ["공포", "사랑", "스릴러", "판타지", "액션"];

async function main() {
  const token = await hre.ethers.getContractFactory("Token");
  const tokenContract = await token.deploy();

  const basicLiterary = await hre.ethers.getContractFactory("LiteraryWork");
  const literaryContract = await basicLiterary.deploy();

  const factory = await hre.ethers.getContractFactory("LiteraryFactory");
  const factoryContract = await factory.deploy(
    categoryList,
    literaryContract.address,
    tokenContract.address
  );

  // const controller = await hre.ethers.getContractFactory("Controller");
  // const controllerContract = await controller.deploy(factoryContract.address);

  // await factoryContract.setStorageAddress(controllerContract.address);

  makeFactoryJSON(factoryContract.address);
  makeTokenJSON(tokenContract.address);
  makeWorkJSON();

  console.log("success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
