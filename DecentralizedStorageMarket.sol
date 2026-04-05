// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DecentralizedStorageMarket {
    struct StorageOrder {
        address client;
        address provider;
        uint256 sizeMB;
        uint256 price;
        uint256 duration;
        uint256 startTime;
        bool active;
    }

    uint256 public orderId;
    mapping(uint256 => StorageOrder) public orders;

    event OrderCreated(uint256 indexed id, address client, uint256 size, uint256 price);
    event OrderAccepted(uint256 indexed id, address provider);
    event OrderCompleted(uint256 indexed id);

    function createOrder(uint256 sizeMB, uint256 duration) external payable {
        require(msg.value > 0, "No payment");
        uint256 id = orderId++;
        orders[id] = StorageOrder({
            client: msg.sender,
            provider: address(0),
            sizeMB: sizeMB,
            price: msg.value,
            duration: duration,
            startTime: 0,
            active: false
        });
        emit OrderCreated(id, msg.sender, sizeMB, msg.value);
    }

    function acceptOrder(uint256 id) external {
        StorageOrder storage order = orders[id];
        require(order.client != address(0), "Invalid order");
        require(order.provider == address(0), "Already accepted");
        order.provider = msg.sender;
        order.startTime = block.timestamp;
        order.active = true;
        emit OrderAccepted(id, msg.sender);
    }

    function completeOrder(uint256 id) external {
        StorageOrder storage order = orders[id];
        require(msg.sender == order.provider, "Not provider");
        require(order.active, "Not active");
        require(block.timestamp >= order.startTime + order.duration, "Not expired");
        order.active = false;
        payable(order.provider).transfer(order.price);
        emit OrderCompleted(id);
    }
}
