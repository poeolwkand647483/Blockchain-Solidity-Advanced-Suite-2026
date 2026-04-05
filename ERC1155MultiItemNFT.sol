// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155MultiItemNFT is ERC1155, Ownable {
    string public name = "MultiItem NFT Collection";
    string public symbol = "MINFT";
    mapping(uint256 => string) public tokenURIs;

    constructor() ERC1155("") Ownable(msg.sender) {}

    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts, string[] calldata uris) external onlyOwner {
        require(ids.length == amounts.length && ids.length == uris.length, "Length mismatch");
        _mintBatch(to, ids, amounts, "");
        for (uint256 i; i < ids.length; i++) {
            tokenURIs[ids[i]] = uris[i];
        }
    }

    function mintSingle(address to, uint256 id, uint256 amount, string calldata uri) external onlyOwner {
        _mint(to, id, amount, "");
        tokenURIs[id] = uri;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return tokenURIs[id];
    }
}
