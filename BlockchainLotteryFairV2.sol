// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BlockchainLotteryFairV2 is ReentrancyGuard {
    address public manager;
    uint256 public ticketPrice = 0.01 ether;
    uint256 public maxTickets = 100;
    address[] public participants;
    bool public lotteryEnded;

    event TicketPurchased(address indexed buyer);
    event WinnerSelected(address indexed winner, uint256 prize);

    constructor() {
        manager = msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Not manager");
        _;
    }

    function buyTicket() external payable nonReentrant {
        require(msg.value == ticketPrice, "Wrong price");
        require(participants.length < maxTickets, "Full");
        require(!lotteryEnded, "Ended");
        participants.push(msg.sender);
        emit TicketPurchased(msg.sender);
    }

    function drawWinner() external onlyManager nonReentrant {
        require(participants.length > 0, "No participants");
        require(!lotteryEnded, "Ended");
        uint256 index = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % participants.length;
        address winner = participants[index];
        uint256 prize = address(this).balance;
        payable(winner).transfer(prize);
        lotteryEnded = true;
        emit WinnerSelected(winner, prize);
    }

    function resetLottery() external onlyManager {
        require(lotteryEnded, "Not ended");
        delete participants;
        lotteryEnded = false;
    }
}
