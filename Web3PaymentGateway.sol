// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Web3PaymentGateway {
    address public merchant;
    mapping(bytes32 => bool) public processedOrders;

    event PaymentReceived(address indexed payer, bytes32 indexed orderId, uint256 amount);

    constructor() {
        merchant = msg.sender;
    }

    function payOrder(bytes32 orderId) external payable {
        require(!processedOrders[orderId], "Processed");
        require(msg.value > 0, "Zero payment");
        processedOrders[orderId] = true;
        payable(merchant).transfer(msg.value);
        emit PaymentReceived(msg.sender, orderId, msg.value);
    }

    function isOrderPaid(bytes32 orderId) external view returns (bool) {
        return processedOrders[orderId];
    }
}
