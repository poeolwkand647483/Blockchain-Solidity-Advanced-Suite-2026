// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTBlindBoxOpening is Ownable {
    IERC721 public immutable nft;
    uint256 public boxPrice = 0.05 ether;
    uint256[] public availableTokenIds;

    constructor(address _nft) Ownable(msg.sender) {
        nft = IERC721(_nft);
    }

    function addTokensToBox(uint256[] calldata tokenIds) external onlyOwner {
        for (uint256 i; i < tokenIds.length; i++) {
            availableTokenIds.push(tokenIds[i]);
        }
    }

    function openBlindBox() external payable returns (uint256) {
        require(msg.value == boxPrice, "Wrong price");
        require(availableTokenIds.length > 0, "No boxes");
        uint256 index = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % availableTokenIds.length;
        uint256 tokenId = availableTokenIds[index];
        availableTokenIds[index] = availableTokenIds[availableTokenIds.length - 1];
        availableTokenIds.pop();
        nft.transferFrom(address(this), msg.sender, tokenId);
        return tokenId;
    }
}
