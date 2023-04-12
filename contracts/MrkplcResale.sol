// SPDX-License-Identifier: BLANK

// pragma
pragma solidity 0.8.15;

// imports
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// error codes
error MrkplcResale__NotHolder();

// Interfaces

// Libraries

// Contracts

// Contract Address: 0xe4B139bE66f03ac66C882F54592f01cf0edE2af7

/// @title A Contract For Nft Resale
/// @author keenregen
/// @notice A mrkplc contract for study purposes
/// @custom:experimental This is an experimental contract.
contract MrkplcResale is IERC721Receiver, ReentrancyGuard, Ownable {
    address payable holder;
    uint256 listingFee = 0.000001 ether;

    struct List {
        uint256 tokenId;
        address payable seller;
        address payable holder;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => List) public fairItems;

    event NftListed(
        uint256 indexed tokenId,
        address seller,
        address holder,
        uint256 price,
        bool sold
    );

    ERC721Enumerable nft;

    // Modifiers

    modifier onlyHolder() {
        // require(msg.sender == holder, "Sender must be contract holder.");
        // gas efficient way for errors
        if (msg.sender != holder) revert MrkplcResale__NotHolder();
        _;
    }

    // Functions (const, rec, fallback, external, public, internal, private, view/pure)

    // called when the contract is deployed
    constructor(ERC721Enumerable _nft) {
        holder = payable(msg.sender);
        nft = _nft;
    }

    function withdraw() public payable onlyHolder {
        require(payable(msg.sender).send(address(this).balance));
    }

    function listSale(
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(nft.ownerOf(tokenId) == msg.sender, "Nft is not yours");
        require(fairItems[tokenId].tokenId == 0, "Nft was already listed");
        require(price > 0, "Amount must be higher than 0");
        require(
            msg.value == listingFee,
            "Please transfer 0.000001 ether to pay listing fee"
        );
        fairItems[tokenId] = List(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
        nft.transferFrom(msg.sender, address(this), tokenId);
        emit NftListed(tokenId, msg.sender, address(this), price, false);
    }

    function buyNft(uint256 tokenId) public payable nonReentrant {
        uint256 price = fairItems[tokenId].price;
        require(
            msg.value == price,
            "Transfer price amount to complete transaction"
        );
        fairItems[tokenId].seller.transfer(msg.value);
        nft.transferFrom(address(this), msg.sender, tokenId);
        fairItems[tokenId].sold = true;
        delete fairItems[tokenId];
    }

    function cancelSale(uint256 tokenId) public nonReentrant {
        require(fairItems[tokenId].seller == msg.sender, "NFT not yours");
        nft.transferFrom(address(this), msg.sender, tokenId);
        delete fairItems[tokenId];
    }

    function getPrice(uint256 tokenId) public view returns (uint256) {
        uint256 price = fairItems[tokenId].price;
        return price;
    }

    function nftListings() public view returns (List[] memory) {
        uint256 nftCount = nft.totalSupply();
        uint currentIndex = 0;
        List[] memory items = new List[](nftCount);
        for (uint i = 0; i < nftCount; i++) {
            if (fairItems[i + 1].holder == address(this)) {
                uint currentId = i + 1;
                List storage currentItem = fairItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send nfts to nftFair directly");
        return IERC721Receiver.onERC721Received.selector;
    }

    function getListingFee() public view returns (uint256) {
        return listingFee;
    }
}
