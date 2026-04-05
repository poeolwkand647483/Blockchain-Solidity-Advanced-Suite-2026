// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceTreasuryManager is Ownable {
    mapping(address => bool) public approvedTokens;
    mapping(address => uint256) public tokenBalances;

    event TokenDeposited(address indexed token, address indexed user, uint256 amount);
    event TokenWithdrawn(address indexed token, address indexed to, uint256 amount);
    event TokenApproved(address indexed token);

    constructor() Ownable(msg.sender) {}

    function approveToken(address token) external onlyOwner {
        approvedTokens[token] = true;
        emit TokenApproved(token);
    }

    function depositToken(address token, uint256 amount) external {
        require(approvedTokens[token], "Token not approved");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        tokenBalances[token] += amount;
        emit TokenDeposited(token, msg.sender, amount);
    }

    function withdrawToken(address token, address to, uint256 amount) external onlyOwner {
        require(tokenBalances[token] >= amount, "Insufficient balance");
        tokenBalances[token] -= amount;
        IERC20(token).transfer(to, amount);
        emit TokenWithdrawn(token, to, amount);
    }

    function getTreasuryBalance(address token) external view returns (uint256) {
        return tokenBalances[token];
    }
}
