// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DeFiFlashLoanArbitrage is FlashLoanSimpleReceiverBase, Ownable {
    constructor(address _pool) FlashLoanSimpleReceiverBase(IPool(_pool)) Ownable(msg.sender) {}

    function executeFlashLoan(address token, uint256 amount) external onlyOwner {
        address receiver = address(this);
        bytes memory params = "";
        uint256 referralCode = 0;
        POOL.flashLoanSimple(receiver, token, amount, params, referralCode);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address,
        bytes calldata
    ) external override returns (bool) {
        uint256 total = amount + premium;
        IERC20(asset).approve(address(POOL), total);
        return true;
    }

    function withdrawToken(address token) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, bal);
    }
}
