// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract OraclePriceFeedConsumer {
    AggregatorV3Interface internal priceFeed;
    address public owner;

    constructor(address _feed) {
        priceFeed = AggregatorV3Interface(_feed);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function getLatestPrice() public view returns (int256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        return price;
    }

    function getPriceDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }

    function updateOracleFeed(address newFeed) external onlyOwner {
        priceFeed = AggregatorV3Interface(newFeed);
    }
}
