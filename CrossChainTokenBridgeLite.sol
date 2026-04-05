// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrossChainTokenBridgeLite is Ownable {
    IERC20 public immutable token;
    address public bridgeValidator;
    mapping(bytes32 => bool) public processedTransfers;

    event BridgeInitiated(address indexed sender, uint256 amount, uint256 chainId);
    event BridgeCompleted(address indexed recipient, uint256 amount);

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function setValidator(address _validator) external onlyOwner {
        bridgeValidator = _validator;
    }

    function initiateBridge(uint256 amount, uint256 targetChain) external {
        require(amount > 0, "Zero amount");
        token.transferFrom(msg.sender, address(this), amount);
        emit BridgeInitiated(msg.sender, amount, targetChain);
    }

    function completeBridge(address recipient, uint256 amount, bytes32 transferId) external {
        require(msg.sender == bridgeValidator, "Not validator");
        require(!processedTransfers[transferId], "Processed");
        processedTransfers[transferId] = true;
        token.transfer(recipient, amount);
        emit BridgeCompleted(recipient, amount);
    }
}
