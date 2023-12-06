// SPDX-License-Identifier: MIT

/*
    This contract is the Bike Sharing utility token with the following tokenomics:
    - Has an initial supply of 1,000,000,000 tokens
    - CALs get minted as a staking reward 
    - CALs get burned when users rent a bike, proportionally to the number of Kms
    - Users that stake CAL have a say in the Bike Sharing DAO
    - Users that stake CAL get discounts on bike rentals
    - More CALs can be minted the DAO if the community votes for it
    - CAL can be bought and sold on the open market (mimo.exchange)
*/

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
