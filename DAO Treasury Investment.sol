// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAOTreasuryInvestment is Ownable {
    IERC20 public immutable usdt;
    uint256 public totalInvested;
    mapping(address => uint256) public userInvestments;

    event Invested(address indexed user, uint256 amount);
    event DividendDistributed(address indexed user, uint256 dividend);

    constructor(address _usdt) Ownable(msg.sender) {
        usdt = IERC20(_usdt);
    }

    function invest(uint256 amount) external {
        require(amount > 0, "Zero amount");
        usdt.transferFrom(msg.sender, address(this), amount);
        userInvestments[msg.sender] += amount;
        totalInvested += amount;
        emit Invested(msg.sender, amount);
    }

    function distributeDividend(address[] calldata users, uint256[] calldata dividends) external onlyOwner {
        require(users.length == dividends.length, "Mismatch");
        for (uint256 i; i < users.length; i++) {
            usdt.transfer(users[i], dividends[i]);
            emit DividendDistributed(users[i], dividends[i]);
        }
    }
}
