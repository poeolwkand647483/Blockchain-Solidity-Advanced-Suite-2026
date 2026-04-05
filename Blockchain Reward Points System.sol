// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract BlockchainRewardPointsSystem {
    mapping(address => uint256) public points;
    address public owner;

    event PointsAdded(address indexed user, uint256 amount);
    event PointsRedeemed(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function addPoints(address user, uint256 amount) external onlyOwner {
        points[user] += amount;
        emit PointsAdded(user, amount);
    }

    function redeemPoints(uint256 amount) external {
        require(points[msg.sender] >= amount, "Insufficient points");
        points[msg.sender] -= amount;
        emit PointsRedeemed(msg.sender, amount);
    }
}
