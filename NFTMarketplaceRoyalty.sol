// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarketplaceRoyalty is ReentrancyGuard {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    uint256 public listingId;
    mapping(uint256 => Listing) public listings;
    uint256 public platformFee = 250; // 2.5%
    address public feeReceiver;

    event NFTListed(uint256 indexed id, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed id, address indexed buyer, uint256 price);
    event ListingCancelled(uint256 indexed id);

    constructor() {
        feeReceiver = msg.sender;
    }

    function listNFT(address nft, uint256 tokenId, uint256 price) external nonReentrant {
        require(price > 0, "Zero price");
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        uint256 id = listingId++;
        listings[id] = Listing({
            seller: msg.sender,
            nftContract: nft,
            tokenId: tokenId,
            price: price,
            active: true
        });
        emit NFTListed(id, msg.sender, price);
    }

    function buyNFT(uint256 id) external payable nonReentrant {
        Listing storage list = listings[id];
        require(list.active, "Not active");
        require(msg.value == list.price, "Wrong price");
        list.active = false;
        uint256 fee = (list.price * platformFee) / 10000;
        payable(feeReceiver).transfer(fee);
        payable(list.seller).transfer(list.price - fee);
        IERC721(list.nftContract).transferFrom(address(this), msg.sender, list.tokenId);
        emit NFTSold(id, msg.sender, list.price);
    }

    function cancelListing(uint256 id) external nonReentrant {
        Listing storage list = listings[id];
        require(msg.sender == list.seller, "Not seller");
        require(list.active, "Not active");
        list.active = false;
        IERC721(list.nftContract).transferFrom(address(this), msg.sender, list.tokenId);
        emit ListingCancelled(id);
    }
}
