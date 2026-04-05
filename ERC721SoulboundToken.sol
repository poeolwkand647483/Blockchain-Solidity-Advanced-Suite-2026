// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721SoulboundToken is ERC721, Ownable {
    uint256 public tokenIdCounter;
    mapping(uint256 => string) public tokenData;

    constructor() ERC721("Soulbound Identity", "SBT") Ownable(msg.sender) {}

    function mintSBT(address to, string calldata data) external onlyOwner {
        uint256 tokenId = tokenIdCounter++;
        _mint(to, tokenId);
        tokenData[tokenId] = data;
    }

    function _transfer(address from, address to, uint256 tokenId) internal pure override {
        revert("Soulbound: non-transferable");
    }
}
