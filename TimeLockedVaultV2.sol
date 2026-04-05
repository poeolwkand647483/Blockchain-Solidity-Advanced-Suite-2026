// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract TimeLockedVaultV2 {
    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Lock) public userLocks;

    event Deposited(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);

    function deposit(uint256 lockDuration) external payable {
        require(msg.value > 0, "Zero deposit");
        require(userLocks[msg.sender].amount == 0, "Existing lock");
        uint256 unlock = block.timestamp + lockDuration;
        userLocks[msg.sender] = Lock({
            amount: msg.value,
            unlockTime: unlock
        });
        emit Deposited(msg.sender, msg.value, unlock);
    }

    function withdraw() external {
        Lock memory lock = userLocks[msg.sender];
        require(lock.amount > 0, "No deposit");
        require(block.timestamp >= lock.unlockTime, "Locked");
        uint256 amount = lock.amount;
        delete userLocks[msg.sender];
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getUnlockTime(address user) external view returns (uint256) {
        return userLocks[user].unlockTime;
    }
}
