// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AutoCompoundYieldFarming is ReentrancyGuard {
    IERC20 public immutable stakeToken;
    IERC20 public immutable rewardToken;
    uint256 public lastCompound;
    uint256 public compoundInterval = 1 days;

    mapping(address => uint256) public userShares;
    uint256 public totalShares;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Compounded(uint256 reward);

    constructor(address _stake, address _reward) {
        stakeToken = IERC20(_stake);
        rewardToken = IERC20(_reward);
        lastCompound = block.timestamp;
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Zero amount");
        stakeToken.transferFrom(msg.sender, address(this), amount);
        uint256 share = totalShares == 0 ? amount : (amount * totalShares) / stakeToken.balanceOf(address(this));
        userShares[msg.sender] += share;
        totalShares += share;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 share) external nonReentrant {
        require(userShares[msg.sender] >= share, "Insufficient share");
        uint256 amount = (share * stakeToken.balanceOf(address(this))) / totalShares;
        userShares[msg.sender] -= share;
        totalShares -= share;
        stakeToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function compound() external {
        require(block.timestamp >= lastCompound + compoundInterval, "Too soon");
        uint256 reward = rewardToken.balanceOf(address(this));
        if (reward > 0) {
            // Auto-compound logic: convert reward to stake token
            emit Compounded(reward);
        }
        lastCompound = block.timestamp;
    }
}
