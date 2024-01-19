/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require('hardhat-deploy');
require("dotenv").config();

require("./tasks");

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
     evmVersion: "paris"
    },
  },
  networks: {
    testnet: {
      url: "https://rpc.goerli.linea.build",
      accounts: [process.env.PRIVATE_KEY],
    },
    mainnet: {
      url: "https://rpc.linea.build",
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};
