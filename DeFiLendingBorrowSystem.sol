// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DeFiLendingBorrowSystem is ReentrancyGuard {
    IERC20 public immutable collateralToken;
    IERC20 public immutable loanToken;
    uint256 public loanToValue = 5000; // 50%

    mapping(address => uint256) public collateralDeposits;
    mapping(address => uint256) public loans;

    event CollateralDeposited(address indexed user, uint256 amount);
    event LoanTaken(address indexed user, uint256 amount);
    event LoanRepaid(address indexed user, uint256 amount);

    constructor(address _collateral, address _loan) {
        collateralToken = IERC20(_collateral);
        loanToken = IERC20(_loan);
    }

    function depositCollateral(uint256 amount) external nonReentrant {
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralDeposits[msg.sender] += amount;
        emit CollateralDeposited(msg.sender, amount);
    }

    function borrow(uint256 amount) external nonReentrant {
        uint256 maxLoan = (collateralDeposits[msg.sender] * loanToValue) / 10000;
        require(loans[msg.sender] + amount <= maxLoan, "Over LTV");
        loans[msg.sender] += amount;
        loanToken.transfer(msg.sender, amount);
        emit LoanTaken(msg.sender, amount);
    }

    function repayLoan(uint256 amount) external nonReentrant {
        loanToken.transferFrom(msg.sender, address(this), amount);
        loans[msg.sender] -= amount;
        emit LoanRepaid(msg.sender, amount);
    }
}
