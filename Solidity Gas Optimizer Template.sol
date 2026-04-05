// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SolidityGasOptimizerTemplate {
    uint256 public immutable immutableVar;
    uint256 public constant constantVar = 100;
    uint256 public storedVar;

    constructor(uint256 _immutable) {
        immutableVar = _immutable;
    }

    function writeStorage(uint256 value) external {
        storedVar = value;
    }

    function readStorage() external view returns (uint256) {
        return storedVar;
    }

    function mathOperation(uint256 a, uint256 b) external pure returns (uint256) {
        return a * b + a / b - a % b;
    }
}
