// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTStakingRewardMachine is ReentrancyGuard {
    IERC721 public immutable nftContract;
    IERC20 public immutable rewardToken;
    uint256 public rewardPerNFT = 10 ether;
    uint256 public rewardInterval = 1 days;

    struct Stake {
        uint256 tokenId;
        uint256 startTime;
        uint256 lastClaim;
    }

    mapping(address => Stake[]) public userStakes;

    event NFTStaked(address indexed user, uint256 tokenId);
    event NFTUnstaked(address indexed user, uint256 tokenId);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address _nft, address _reward) {
        nftContract = IERC721(_nft);
        rewardToken = IERC20(_reward);
    }

    function stakeNFT(uint256 tokenId) external nonReentrant {
        nftContract.transferFrom(msg.sender, address(this), tokenId);
        userStakes[msg.sender].push(Stake({
            tokenId: tokenId,
            startTime: block.timestamp,
            lastClaim: block.timestamp
        }));
        emit NFTStaked(msg.sender, tokenId);
    }

    function unstakeNFT(uint256 index) external nonReentrant {
        require(index < userStakes[msg.sender].length, "Invalid index");
        Stake memory stake = userStakes[msg.sender][index];
        _claimReward(msg.sender, index);
        nftContract.transferFrom(address(this), msg.sender, stake.tokenId);
        userStakes[msg.sender][index] = userStakes[msg.sender][userStakes[msg.sender].length - 1];
        userStakes[msg.sender].pop();
        emit NFTUnstaked(msg.sender, stake.tokenId);
    }

    function claimAllRewards() external nonReentrant {
        uint256 total;
        for (uint256 i; i < userStakes[msg.sender].length; i++) {
            total += _calculateReward(msg.sender, i);
            userStakes[msg.sender][i].lastClaim = block.timestamp;
        }
        require(total > 0, "No reward");
        rewardToken.transfer(msg.sender, total);
        emit RewardClaimed(msg.sender, total);
    }

    function _calculateReward(address user, uint256 index) internal view returns (uint256) {
        Stake memory stake = userStakes[user][index];
        uint256 elapsed = block.timestamp - stake.lastClaim;
        return (elapsed * rewardPerNFT) / rewardInterval;
    }

    function _claimReward(address user, uint256 index) internal {
        uint256 reward = _calculateReward(user, index);
        if (reward > 0) {
            rewardToken.transfer(user, reward);
            emit RewardClaimed(user, reward);
        }
    }
}
