// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenVestingSchedule is Ownable {
    struct Vesting {
        uint256 totalAmount;
        uint256 claimed;
        uint256 startTime;
        uint256 duration;
        uint256 cliff;
    }

    IERC20 public immutable token;
    mapping(address => Vesting) public vestings;

    event VestingCreated(address indexed beneficiary, uint256 total, uint256 cliff, uint256 duration);
    event TokensClaimed(address indexed beneficiary, uint256 amount);

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function createVesting(address beneficiary, uint256 total, uint256 cliff, uint256 duration) external onlyOwner {
        require(vestings[beneficiary].totalAmount == 0, "Existing vesting");
        vestings[beneficiary] = Vesting({
            totalAmount: total,
            claimed: 0,
            startTime: block.timestamp,
            duration: duration,
            cliff: cliff
        });
        emit VestingCreated(beneficiary, total, cliff, duration);
    }

    function claimVestedTokens() external {
        Vesting storage vest = vestings[msg.sender];
        require(block.timestamp >= vest.startTime + vest.cliff, "Cliff active");
        uint256 elapsed = block.timestamp - vest.startTime;
        uint256 vested = (vest.totalAmount * elapsed) / vest.duration;
        uint256 claimable = vested - vest.claimed;
        require(claimable > 0, "No claimable");
        vest.claimed += claimable;
        token.transfer(msg.sender, claimable);
        emit TokensClaimed(msg.sender, claimable);
    }
}
