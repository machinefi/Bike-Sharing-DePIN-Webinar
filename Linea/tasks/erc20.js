
task("startRide", "Request a new ride")
  .addParam("bikeid", "Unique id of the bike")
  .addParam("depositamount", "Amount of deposit estimated for the ride")
  .setAction(async (taskArgs, hre) => {
    const { bikeid, depositamount } = taskArgs;
    const { deployments } = hre;
    const [deployer] = await ethers.getSigners();

    // Log all available deployments
    const Token = await deployments.get("BikeSharingToken");
    const token = await ethers.getContractAt("BikeSharingToken", Token.address, deployer);

    const tx = await token.startRide(bikeid, depositamount);

    await tx.wait();

    console.log(`New ride created with Ride Id ${tx.events[0].args.rideId}`);
  });
