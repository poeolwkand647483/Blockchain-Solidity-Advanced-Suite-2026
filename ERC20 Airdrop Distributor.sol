// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20AirdropDistributor is Ownable {
    IERC20 public immutable token;

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function airdrop(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Mismatch");
        for (uint256 i; i < recipients.length; i++) {
            token.transfer(recipients[i], amounts[i]);
        }
    }

    function airdropFixed(address[] calldata recipients, uint256 amount) external onlyOwner {
        for (uint256 i; i < recipients.length; i++) {
            token.transfer(recipients[i], amount);
        }
    }
}
