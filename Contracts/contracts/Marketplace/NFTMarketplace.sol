// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _listingIds;

    struct Listing {
        uint256 listingId;
        address nftContract;
        uint256 tokenId;
        address seller;
        uint256 price;
        bool isActive;
    }

    mapping(uint256 => Listing) public listings;
    uint256 public platformFee = 25; // 2.5%

    event ListingCreated(
        uint256 indexed listingId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );
    event ListingSold(
        uint256 indexed listingId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price
    );
    event ListingCanceled(uint256 indexed listingId);

    function createListing(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant {
        require(price > 0, "Price must be greater than 0");
        
        IERC721 nft = IERC721(nftContract);
        require(
            nft.ownerOf(tokenId) == msg.sender,
            "Not the owner of this NFT"
        );
        require(
            nft.getApproved(tokenId) == address(this),
            "NFT not approved for marketplace"
        );

        _listingIds.increment();
        uint256 listingId = _listingIds.current();

        listings[listingId] = Listing(
            listingId,
            nftContract,
            tokenId,
            msg.sender,
            price,
            true
        );

        emit ListingCreated(listingId, nftContract, tokenId, msg.sender, price);
    }

    function buyNFT(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is not active");
        require(msg.value >= listing.price, "Insufficient payment");

        listing.isActive = false;
        
        uint256 platformFeeAmount = (listing.price * platformFee) / 1000;
        uint256 sellerAmount = listing.price - platformFeeAmount;

        IERC721(listing.nftContract).safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        payable(listing.seller).transfer(sellerAmount);

        emit ListingSold(
            listingId,
            listing.nftContract,
            listing.tokenId,
            listing.seller,
            msg.sender,
            listing.price
        );
    }

    function cancelListing(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Not the seller");
        require(listing.isActive, "Listing is not active");

        listing.isActive = false;

        emit ListingCanceled(listingId);
    }
}