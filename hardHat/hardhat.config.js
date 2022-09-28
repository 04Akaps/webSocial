require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

// https://goerli.infura.io/v3/cf51080a391a4c9fab88d891e49d93e8
// https://rinkeby.infura.io/v3/cf51080a391a4c9fab88d891e49d93e8

module.exports = {
  defaultnetwork: "localhost",

  networks: {
    rinkeby: {
      url: "https://goerli.infura.io/v3/cf51080a391a4c9fab88d891e49d93e8",
      accounts: [
        "4fdbe4cf7ea3bf1408794f1cfdfc9c551ab9195c9f475f0d379c8eb2911f241f",
      ],
    },
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  mocha: {
    timeout: 40000,
  },
};
