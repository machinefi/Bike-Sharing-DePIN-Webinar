module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying with account: ", deployer);
  console.log("Account balance: ", (await ethers.provider.getBalance(deployer)).toString());

  const tx = await deploy("BikeNFT", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log("BikeNFT deployed at block: ", tx.receipt.blockNumber);
  
};
module.exports.tags = ["BikeNFT"];
