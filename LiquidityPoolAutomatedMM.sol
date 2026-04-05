// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityPoolAutomatedMM {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    uint256 public reserveA;
    uint256 public reserveB;

    event LiquidityAdded(address indexed user, uint256 a, uint256 b);
    event LiquidityRemoved(address indexed user, uint256 a, uint256 b);
    event Swapped(address indexed user, address inToken, uint256 inAmt, uint256 outAmt);

    constructor(address _a, address _b) {
        tokenA = IERC20(_a);
        tokenB = IERC20(_b);
    }

    function _updateReserves() internal {
        reserveA = tokenA.balanceOf(address(this));
        reserveB = tokenB.balanceOf(address(this));
    }

    function addLiquidity(uint256 amtA, uint256 amtB) external {
        tokenA.transferFrom(msg.sender, address(this), amtA);
        tokenB.transferFrom(msg.sender, address(this), amtB);
        _updateReserves();
        emit LiquidityAdded(msg.sender, amtA, amtB);
    }

    function swap(address inToken, uint256 inAmt) external returns (uint256) {
        require(inToken == address(tokenA) || inToken == address(tokenB), "Invalid token");
        IERC20(inToken).transferFrom(msg.sender, address(this), inAmt);
        _updateReserves();
        uint256 outAmt;
        if (inToken == address(tokenA)) {
            outAmt = (reserveB * inAmt) / (reserveA + inAmt);
            tokenB.transfer(msg.sender, outAmt);
        } else {
            outAmt = (reserveA * inAmt) / (reserveB + inAmt);
            tokenA.transfer(msg.sender, outAmt);
        }
        _updateReserves();
        emit Swapped(msg.sender, inToken, inAmt, outAmt);
        return outAmt;
    }
}
