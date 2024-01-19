module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // Get the address of the deployed BikeNFT contract
  const BikeNFT = await deployments.get("BikeNFT");

  const tx = await deploy("BikeSharingToken", {
    from: deployer,
    args: [ BikeNFT.address ],
    log: true,
  });

  console.log("Token deployed at block: ", tx.receipt.blockNumber);
};
module.exports.tags = ["BikeSharingToken"];
