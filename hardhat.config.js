require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
console.log(process.env.SEPOLIA_TESTNET_RPC);
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    hardhat: {
      chainId: 1337
    },
    sepolia: {
      chainId: 11155111,
      url: process.env.SEPOLIA_TESTNET_RPC,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
