// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SmartContractAuditLog {
    struct Log {
        address caller;
        string action;
        uint256 timestamp;
        bytes data;
    }

    Log[] public logs;

    event LogRecorded(address indexed caller, string action, uint256 time);

    function recordLog(string calldata action, bytes calldata data) external {
        logs.push(Log({
            caller: msg.sender,
            action: action,
            timestamp: block.timestamp,
            data: data
        }));
        emit LogRecorded(msg.sender, action, block.timestamp);
    }

    function getLogCount() external view returns (uint256) {
        return logs.length;
    }
}
