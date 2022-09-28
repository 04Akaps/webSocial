const hre = require("hardhat");
const { ethers } = hre;
const { expect } = require("chai");

const literaryWorkABI =
  require("../artifacts/contracts/NFTContract/LiteraryWork.sol/LiteraryWork.json").abi;

// const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

const categoryList = ["공포", "사랑", "스릴러", "판타지", "액션"];

const threeDays = 259200;
const oneDays = 86400;
const oneHours = 3600;

const contractDeploy = async () => {
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

  return factoryContract;
};

const makeNewliteraryWork = async () => {
  const [owner, otherAccount] = await ethers.getSigners();

  const factory = await contractDeploy();

  const newWork = await factory.functions.makeNewWork(
    "MyTest Literary",
    "For Hardhat Test Just Do It",
    1,
    false,
    false,
    1,
    oneHours
  );
  await newWork.wait();

  const totalLiteraryWork = await factory.viewTotalLiteraryWork();

  const newLiterary = await hre.ethers.getContractAt(
    literaryWorkABI,
    totalLiteraryWork[0]
  );

  return [newLiterary, owner, otherAccount];
};

describe("Basic Factory Contract Status && Deploy", () => {
  it("deployFactory Contract", async () => {
    const factory = await contractDeploy();

    console.log();
    console.log(`Deployed Factory Address ---------- ${factory.address}`);
    console.log();
  });

  it("view CateGorys", async () => {
    const factory = await contractDeploy();

    const contractCategoryList = await factory.viewCategorys();

    console.log();
    console.log(`current Category ---------- ${categoryList}`);
    console.log();

    for (let i = 0; i < contractCategoryList.length; i++) {
      expect(contractCategoryList[i]).to.equal(categoryList[i]);
    }
  });
});

describe("Make New Literary", () => {
  it("deployFactory And MakeNewWork", async () => {
    const factory = await contractDeploy();

    const newWork = await factory.functions.makeNewWork(
      "MyTest Literary",
      "For Hardhat Test Just Do It",
      1,
      false,
      true,
      1,
      oneHours
    );
    await newWork.wait();

    const totalLiteraryWork = await factory.viewTotalLiteraryWork();

    console.log();
    console.log(`newLiteraryWork's Address ---------- ${totalLiteraryWork[0]}`);
    console.log();
  });

  it("mint NewWork", async () => {
    const [literary, writer, user] = await makeNewliteraryWork();

    await literary.mint(100, "testTokenURL", 0);

    const balance = await literary.balanceOf(writer.address, 0);
    console.log(balance);
  });
});
