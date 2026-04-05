// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTRoyaltySplitter is Ownable {
    address[] public recipients;
    uint256[] public shares;
    uint256 public totalShares;

    constructor(address[] memory _recipients, uint256[] memory _shares) Ownable(msg.sender) {
        require(_recipients.length == _shares.length, "Mismatch");
        recipients = _recipients;
        shares = _shares;
        for (uint256 i; i < _shares.length; i++) totalShares += _shares[i];
    }

    function distribute() external payable {
        for (uint256 i; i < recipients.length; i++) {
            uint256 amount = (msg.value * shares[i]) / totalShares;
            payable(recipients[i]).transfer(amount);
        }
    }
}
