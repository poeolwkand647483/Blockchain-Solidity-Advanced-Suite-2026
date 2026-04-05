// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DecentralizedVotingEscrow {
    IERC20 public immutable token;
    mapping(address => uint256) public lockedBalance;
    mapping(address => uint256) public unlockTime;

    event Locked(address indexed user, uint256 amount, uint256 unlock);
    event Unlocked(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function lockTokens(uint256 amount, uint256 lockTime) external {
        require(amount > 0, "Zero amount");
        require(lockTime >= 7 days, "Min lock 7 days");
        token.transferFrom(msg.sender, address(this), amount);
        lockedBalance[msg.sender] += amount;
        unlockTime[msg.sender] = block.timestamp + lockTime;
        emit Locked(msg.sender, amount, unlockTime[msg.sender]);
    }

    function unlockTokens() external {
        require(block.timestamp >= unlockTime[msg.sender], "Locked");
        uint256 amount = lockedBalance[msg.sender];
        delete lockedBalance[msg.sender];
        delete unlockTime[msg.sender];
        token.transfer(msg.sender, amount);
        emit Unlocked(msg.sender, amount);
    }

    function getVotingPower(address user) external view returns (uint256) {
        return block.timestamp < unlockTime[user] ? lockedBalance[user] : 0;
    }
}
