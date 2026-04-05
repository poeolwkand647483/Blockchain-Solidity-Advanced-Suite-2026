// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract CrossChainMessageRelayer {
    address public validator;
    mapping(bytes32 => bool) public processedMessages;

    event MessageSent(address indexed sender, uint256 targetChain, bytes data);
    event MessageReceived(address indexed recipient, bytes data);

    constructor() {
        validator = msg.sender;
    }

    modifier onlyValidator() {
        require(msg.sender == validator, "Not validator");
        _;
    }

    function sendMessage(uint256 targetChain, bytes calldata data) external {
        emit MessageSent(msg.sender, targetChain, data);
    }

    function receiveMessage(address recipient, bytes calldata data, bytes32 msgId) external onlyValidator {
        require(!processedMessages[msgId], "Processed");
        processedMessages[msgId] = true;
        emit MessageReceived(recipient, data);
    }
}
