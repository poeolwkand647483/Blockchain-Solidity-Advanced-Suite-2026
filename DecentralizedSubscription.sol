// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DecentralizedSubscription {
    address public owner;
    uint256 public monthlyFee = 0.01 ether;
    mapping(address => uint256) public subscriptionExpiry;

    event Subscribed(address indexed user, uint256 expiry);
    event Renewed(address indexed user, uint256 newExpiry);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function subscribe() external payable {
        require(msg.value == monthlyFee, "Wrong fee");
        uint256 expiry = block.timestamp + 30 days;
        subscriptionExpiry[msg.sender] = expiry;
        emit Subscribed(msg.sender, expiry);
    }

    function renew() external payable {
        require(msg.value == monthlyFee, "Wrong fee");
        require(subscriptionExpiry[msg.sender] >= block.timestamp, "Not active");
        subscriptionExpiry[msg.sender] += 30 days;
        emit Renewed(msg.sender, subscriptionExpiry[msg.sender]);
    }

    function isSubscriber(address user) external view returns (bool) {
        return subscriptionExpiry[user] >= block.timestamp;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
