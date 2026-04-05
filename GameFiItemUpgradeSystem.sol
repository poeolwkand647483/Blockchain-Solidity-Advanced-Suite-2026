// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract GameFiItemUpgradeSystem {
    struct GameItem {
        uint256 level;
        uint256 power;
        uint256 lastUpgrade;
    }

    mapping(uint256 => GameItem) public items;
    uint256 public upgradeCooldown = 1 hours;
    uint256 public baseUpgradeCost = 0.001 ether;

    event ItemUpgraded(uint256 indexed itemId, uint256 newLevel, uint256 newPower);

    function registerItem(uint256 itemId) external {
        require(items[itemId].level == 0, "Item exists");
        items[itemId] = GameItem({
            level: 1,
            power: 10,
            lastUpgrade: 0
        });
    }

    function upgradeItem(uint256 itemId) external payable {
        GameItem storage item = items[itemId];
        require(item.level > 0, "Item not exist");
        require(block.timestamp >= item.lastUpgrade + upgradeCooldown, "Cooldown");
        uint256 cost = baseUpgradeCost * item.level;
        require(msg.value >= cost, "Insufficient payment");
        item.level++;
        item.power += 5 * item.level;
        item.lastUpgrade = block.timestamp;
        emit ItemUpgraded(itemId, item.level, item.power);
    }

    function getItemStats(uint256 itemId) external view returns (uint256, uint256) {
        return (items[itemId].level, items[itemId].power);
    }
}
