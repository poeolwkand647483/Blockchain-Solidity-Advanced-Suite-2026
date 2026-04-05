// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTBatchAirdropTool is Ownable {
    constructor() Ownable(msg.sender) {}

    function airdropNFT(address nft, address[] calldata recipients, uint256[] calldata tokenIds) external onlyOwner {
        require(recipients.length == tokenIds.length, "Length mismatch");
        for (uint256 i; i < recipients.length; i++) {
            IERC721(nft).transferFrom(msg.sender, recipients[i], tokenIds[i]);
        }
    }

    function airdropSingleNFT(address nft, address[] calldata recipients, uint256 tokenId) external onlyOwner {
        for (uint256 i; i < recipients.length; i++) {
            IERC721(nft).transferFrom(msg.sender, recipients[i], tokenId + i);
        }
    }
}
