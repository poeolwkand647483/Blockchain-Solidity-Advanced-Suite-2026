// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeFiPortfolioTracker {
    struct Holding {
        address token;
        uint256 amount;
    }

    mapping(address => Holding[]) public portfolio;

    event TokenAdded(address indexed user, address token, uint256 amount);
    event TokenRemoved(address indexed user, address token, uint256 amount);

    function addHolding(address token, uint256 amount) external {
        portfolio[msg.sender].push(Holding({token: token, amount: amount}));
        emit TokenAdded(msg.sender, token, amount);
    }

    function removeHolding(uint256 index) external {
        require(index < portfolio[msg.sender].length, "Invalid index");
        Holding memory hold = portfolio[msg.sender][index];
        portfolio[msg.sender][index] = portfolio[msg.sender][portfolio[msg.sender].length - 1];
        portfolio[msg.sender].pop();
        emit TokenRemoved(msg.sender, hold.token, hold.amount);
    }

    function getHoldingCount(address user) external view returns (uint256) {
        return portfolio[user].length;
    }
}
