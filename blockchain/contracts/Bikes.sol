import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.17;

contract Bikes is ERC721, Ownable {
    string private baseTokenURI;

    constructor() ERC721("Bikes", "BKT") {}

    // Override the tokenURI function to return a fixed image
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        return "ipfs://QmNe6Hv4rZf1JxDtwHzHWbE2ders9qpnR3tRFddxVs4BJ4";
    }

    // Mint a new bike
    function mint(address _to, uint256 _tokenId) public onlyOwner {
        _safeMint(_to, _tokenId);
    }
}