// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SmartContractRateLimiter {
    mapping(address => uint256) public lastCall;
    uint256 public cooldown = 30 seconds;

    modifier rateLimited() {
        require(block.timestamp >= lastCall[msg.sender] + cooldown, "Cooldown");
        _;
        lastCall[msg.sender] = block.timestamp;
    }

    event ActionPerformed(address indexed user);

    function performAction() external rateLimited {
        emit ActionPerformed(msg.sender);
    }

    function setCooldown(uint256 newCooldown) external {
        cooldown = newCooldown;
    }
}
