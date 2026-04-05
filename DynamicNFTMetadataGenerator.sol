// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DynamicNFTMetadataGenerator is ERC721, Ownable {
    uint256 public tokenIdCounter;
    mapping(uint256 => string) public tokenTraits;
    mapping(uint256 => uint256) public tokenRarity;

    constructor() ERC721("Dynamic Meta NFT", "DMNFT") Ownable(msg.sender) {}

    function mintNFT(string calldata traits, uint256 rarity) external {
        require(rarity >= 1 && rarity <= 10, "Rarity 1-10");
        uint256 tokenId = tokenIdCounter++;
        _safeMint(msg.sender, tokenId);
        tokenTraits[tokenId] = traits;
        tokenRarity[tokenId] = rarity;
    }

    function updateTraits(uint256 tokenId, string calldata newTraits) external onlyOwner {
        require(_exists(tokenId), "NFT not exist");
        tokenTraits[tokenId] = newTraits;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "NFT not exist");
        return string(abi.encodePacked(
            "data:application/json,{",
            "\"name\":\"DMNFT #", tokenId, "\",",
            "\"traits\":\"", tokenTraits[tokenId], "\",",
            "\"rarity\":", tokenRarity[tokenId],
            "}"
        ));
    }
}
