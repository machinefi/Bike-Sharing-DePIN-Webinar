# Episode #3

In this third episode of the series, we pick up where we left off last time, continuing our work in the `blockchain` directory: 

## Step 1: Update the `Token.sol` Contract
There are two updates here: 

- We're chaning the name of the contract from a generic `Token.sol` to `BikeCalories.sol`.
- We'll be modifying the constructor to pre-mint an inital supply of our `BCAL` token, and implement a `_transfer()` to allocate 50% of the total supply to the deployer of the contract, which could be the DAO managing this DePIN project for example. This is done with the purpose of allocating a certain portion of the token for airdrop, dev team, partnerships, etc...

Th full `BikeCalories.sol` contract will now look like this: 


 
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BikeCalories is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // The project DAO will be the only minter
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _;
    }

    // The project dApp contract will be the only burner
    modifier onlyBurner() {
        require(hasRole(BURNER_ROLE, msg.sender), "Caller is not a burner");
        _;
    }

    constructor() ERC20("Bike Calories", "BCAL") {
        // We mint an initial supply of 1B tokens to the token contract
        _mint(address(this), 1000000000 * 18**decimals());
        // We transfer 50% to the deployer to  allocate a certain portion 
        // for airdrops, team members, partnerships, and ecosystem development
        _transfer(address(this), msg.sender, 500000000 * 18**decimals());
        
        // After the bootstrap phase, the deployer should be removed as admin
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Apart from the staking contract, that needt to mint rewards,
    // the only other contract that can mint tokens is the DAO
    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }

    // The dApp will burn tokens when users rent a bike
    function burn(address from, uint256 amount) public onlyBurner {
        _burn(from, amount);
    }
}
```

## Step 2: Create the `BikeSharing.sol` Contract

This is the main BikeSharing dApp contract that manages rides, payments and the token economy: 

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
// Import ERC20 from Openzeppelin to manage ioUSDT and CAL tokens
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Import ERC721 from Openzeppelin to check the Bike NFTs ownership
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Import the ZK-Proof verifier contract
import "./IVerifier.sol";
/* 
 * This is the main BikeSharing dApp contract that manages rides, payments,
 * and the token economy
*/ 

contract Bikesharing {
    // These values define the cost of renting a bike
    // and they can be changed by the DAOP
    const WEIGHT_DISTANCE = 1000; // Pay 1 ioUSDT every 1km
    const WEIGHT_DURATION = 2000; // Pay 1 ioUSDT every 8 minutes (roughly)

    // Store the Bikes NFT token address
    ERC721 public bikesAddress;
    // Store the Bike Calories token address
    ERC20 public caloriesAddress;
    // Store the ioUSDT token address
    ERC20 public usdtAddress;
    // Store the ZK-Proof verifier contract address
    IVerifier public verifierAddress;

    // Keeps tracks of the amount of ioUSDT deposited by each user
    mapping(address => uint256) public deposits;

    // Keeps track of the ongoing rides by bikeId
    mapping(uint256 => address) public rides;

    // Constructor
    constructor(address _bikesAddress, 
                address _caloriesAddress, 
                address _usdtAddress,
                address _verifierAddress) {
        bikesAddress = ERC721(_bikesAddress);
        caloriesAddress = ERC20(_caloriesAddress);
        usdtAddress = ERC20(_usdtAddress);
        verifierAddress = IVerifier(_verifierAddress);
    }

    // For a user to rent a bike, they should have deposited the minimum
    // amount of ioUSDT tokens required by the bike owner to ensure 
    // responsible usage of the bikes
    function deposit(uint256 amount) public {
        // Transfer the ioUSDT tokens from the user to the contract
        usdtAddress.transferFrom(msg.sender, address(this), amount);
        // Take note of the amount deposited by the user
        deposits[msg.sender] += amount;
    }

    // Allow a user to start renting a bike. We assume that the bike is 
    // smart enough to check how much the user has deposited, subtract
    // the security deposit, and estimate how long they can ride to stop
    // the bike when the time is up
    function unlockBike(uint256 bikeId) public {
        // Make sure the bike is not already rented
        require(rides[bikeId] == address(0), "Bike is already rented");
        // Check that the user has deposited enough ioUSDT to rent the bike
        // For simplicity, we assume 250 ioUSDT, but this could be
        // defined by the bike owner
        uint256 minDeposit = 250 * 6 * decimals();
        // Minimum ride cost is 1km + 8 minutes
        uint256 minRideCost = calculateRideCost(1 * 1000, 8 * 60);
        require(deposits[msg.sender] >= minDeposit, "Not enough ioUSDT deposited to rent this bike");
        // Check that the remaining deposit is enough to cover for a minimum ride
        require(deposits[msg.sender] - minDeposit >= minRideCost, "Not enough ioUSDT to cover for a minimum ride");

        // Store the ride id by bike id
        rides[bikeId] = msg.sender;
    }

    // This function receives a ZK-Proof that the a ride was completed
    // with some distance and duration. The proof is verified by the
    // dedicated verifier contract. Upon proof verification, the 
    // contract retrieves the owner of the bike from the NFT contract
    // and transfers the 75% of the ride cost from the user to the bike owner.abi
    function lockBike(bytes memory zkProof, 
            uint256 bikeId, uint256 distance, uint256 duration ) public {
        // Verify the zk proof
        bool isValid = verifierAddress.verify(zkProof, bikeId, distance, duration);
        require(isValid, "Invalid zk proof");
        
        // Calculate the ride cost
        uint256 rideCost = calculateRideCost(distance, duration);
        // Calculate the amount to be transferred to the bike owner
        uint256 ownerAmount = rideCost * 75 / 100;
        // Retrieve the bike owner from the NFT contract
        address bikeOwner = bikesAddress.ownerOf(bikeId);
        // Transfer the ride cost to the bike owner
        usdtAddress.transferFrom(msg.sender, bikeOwner, ownerAmount);
        // Close the ride
        rides[bikeId] = address(0);
    }

    // This function calculates the cost of a ride based on kms ridden 
    // and the time of the ride in seconds
    function calculateRideCost(uint256 distance, uint256 duration) public pure returns (uint256) {
        return distance * WEIGHT_DISTANCE + duration * WEIGHT_DURATION;
    }
}
```
