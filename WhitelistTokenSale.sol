// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WhitelistTokenSale is Ownable {
    IERC20 public immutable token;
    uint256 public tokenPrice = 0.001 ether;
    uint256 public maxPurchase = 1000 ether;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public purchases;

    event Whitelisted(address indexed user);
    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function addToWhitelist(address user) external onlyOwner {
        whitelist[user] = true;
        emit Whitelisted(user);
    }

    function addBatchWhitelist(address[] calldata users) external onlyOwner {
        for (uint256 i; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
    }

    function buyTokens() external payable {
        require(whitelist[msg.sender], "Not whitelisted");
        uint256 amount = msg.value / tokenPrice;
        require(purchases[msg.sender] + amount <= maxPurchase, "Over max");
        purchases[msg.sender] += amount;
        token.transfer(msg.sender, amount);
        emit TokensPurchased(msg.sender, amount);
    }

    function withdrawFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
