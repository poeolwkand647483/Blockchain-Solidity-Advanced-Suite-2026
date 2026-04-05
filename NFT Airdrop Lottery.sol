// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTAirdropLottery is Ownable {
    IERC721 public immutable nft;
    address[] public entrants;
    uint256 public prizeTokenId;

    constructor(address _nft) Ownable(msg.sender) {
        nft = IERC721(_nft);
    }

    function setPrize(uint256 tokenId) external onlyOwner {
        prizeTokenId = tokenId;
    }

    function enterLottery() external {
        entrants.push(msg.sender);
    }

    function drawWinner() external onlyOwner {
        require(entrants.length > 0, "No entrants");
        uint256 index = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % entrants.length;
        address winner = entrants[index];
        nft.transferFrom(address(this), winner, prizeTokenId);
        delete entrants;
    }
}
