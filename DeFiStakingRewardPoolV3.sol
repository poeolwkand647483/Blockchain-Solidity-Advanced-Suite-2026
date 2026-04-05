// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DeFiStakingRewardPoolV3 is ReentrancyGuard {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    
    uint256 public rewardRate;
    uint256 public rewardDuration;
    uint256 public rewardEndTime;
    uint256 public totalStaked;
    
    mapping(address => uint256) public userStaked;
    mapping(address => uint256) public userRewardDebt;
    mapping(address => uint256) public userLastClaim;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(address _stake, address _reward, uint256 _rate, uint256 _duration) {
        stakingToken = IERC20(_stake);
        rewardToken = IERC20(_reward);
        rewardRate = _rate;
        rewardDuration = _duration;
    }

    function startReward() external {
        rewardEndTime = block.timestamp + rewardDuration;
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Zero amount");
        stakingToken.transferFrom(msg.sender, address(this), amount);
        userStaked[msg.sender] += amount;
        totalStaked += amount;
        userLastClaim[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(userStaked[msg.sender] >= amount, "Insufficient stake");
        userStaked[msg.sender] -= amount;
        totalStaked -= amount;
        stakingToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claimReward() external nonReentrant {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward");
        rewardToken.transfer(msg.sender, reward);
        userLastClaim[msg.sender] = block.timestamp;
        emit RewardClaimed(msg.sender, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        if (totalStaked == 0 || block.timestamp > rewardEndTime) return 0;
        uint256 timeElapsed = block.timestamp - userLastClaim[user];
        return (userStaked[user] * timeElapsed * rewardRate) / 10000;
    }
}
