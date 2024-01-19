// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BikeNFT is ERC721, Ownable {
    
    constructor() 
        ERC721("Bike NFT", "BIKEN") 
        Ownable(msg.sender) {
            // Let's mint a demo bike to the owner for the demo
            mint(msg.sender, 0x2300ee8d4d4661138be2c7a3a0497086fcdd2aba94f5b9dcfb9169f497024e35);
        }

    // Override the tokenURI function to return a fixed image
    function tokenURI(uint256 _tokenId) public pure override returns (string memory) {
        return "ipfs://QmNe6Hv4rZf1JxDtwHzHWbE2ders9qpnR3tRFddxVs4BJ4";
    }

    // Mint a new bike
    function mint(address _to, uint256 _tokenId) public onlyOwner {
        _safeMint(_to, _tokenId);
    }
}