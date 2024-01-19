// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; // Assuming bikes are NFTs

contract BikeSharingToken is ERC20, Ownable {
    // Assuming there's an NFT contract for bikes
    IERC721 public bikeNFTContract; 

    struct Ride {
        address rider;
        uint256 bikeId;
        uint256 amountDeposited;
    }

    // Keep track of all rides
    uint256 public rideId = 0;
    mapping(uint256 => Ride) public rides;
    // Emitted when a new ride is started
    event RideStarted(uint256 id, address rider, uint256 bikeId, uint256 amountDeposited);
    // Emitted when a ride is ended
    event RideEnded(uint256 id, address rider, uint256 bikeId, uint256 amountDeposited);

    constructor(address bikeNFTAddress)
        ERC20("Bike Sharing Token", "BIKE")
        Ownable(msg.sender)
    {
        bikeNFTContract = IERC721(bikeNFTAddress);
        // Let's mint a few tokens to the owner
        _mint(msg.sender, 1000 * 18**decimals());
    }

    // Starts a new ride
    // This is called by the ride app. Once the tx is completed, the ride app
    // will get the rideId from the event logs and use it to send a message 
    // to the bike to start the ride. The bike will read the ride info from the
    // contract and take note of the amount paid by the rider to stop the ride
    // if it's entirely used up.
    function startRide(uint256 bikeId, uint256 depositAmount) public {
        // Perform the deposit
        require(balanceOf(msg.sender) >= depositAmount, "Insufficient balance");
        transferFrom(msg.sender, address(this), depositAmount);
        // Create the ride
        rides[rideId] = Ride(msg.sender, bikeId, depositAmount);
        // Notify the client with the rideId
        emit RideStarted(rideId, msg.sender, bikeId, depositAmount);
        rideId++;
    }

    // Ends a ride
    // This is called by the w3bstream network upon receiving an end-ride
    // message signed by the bike. The bike will send the rideId and the cost of the
    // ride to the w3bstream network. The network will then verify the signature
    // and compute a zk proof, call this function with the proof to end the ride.
    function endRide(uint256 id, uint256 cost, bytes calldata proof) public {
        require(verifyProof(proof), "Invalid proof");
        Ride memory ride = rides[id];

        address bikeOwner = bikeNFTContract.ownerOf(ride.bikeId);
        transfer(bikeOwner, cost);
        transfer(ride.rider, ride.amountDeposited - cost);

        // Clean up ride record
        delete rides[id];
    }

    function verifyProof(bytes calldata proof) private pure returns (bool) {
        // Placeholder for proof verification logic, this will call the 
        // risc0 verifier contract for this specific project
        return true;
    }
}
