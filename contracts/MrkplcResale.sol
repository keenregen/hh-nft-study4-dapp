// SPDX-License-Identifier: BLANK

// pragma
pragma solidity 0.8.9;

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

/// @title A Contract For Nft Resale
/// @author keenregen
/// @notice A mrkplc contract for study purposes
/// @custom:experimental This is an experimental contract.
contract MrkplcResale is IERC721Receiver, ReentrancyGuard, Ownable {
    address payable holder;
    uint256 listingFee = 0.00001 ether;

    struct List {
        uint256 tokenId;
        address payable seller;
        address payable holder;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => List) public vaultItems;

    event NFTListGenerated(
        uint256 indexed tokenId,
        address seller,
        address holder,
        uint256 price,
        bool sold
    );

    ERC721Enumerable nft;

    // Modifiers

    modifier onlyHolder() {
        // require(msg.sender == i_holder, "Sender must be contract holder.");
        // gas efficient way for errors
        if (msg.sender != i_holder) revert MrkplcResale__NotHolder();
        _;
    }

    // Functions (const, rec, fallback, external, public, internal, private, view/pure)

    // called when the contract is deployed
    constructor(ERC721Enumerable _nft) {
        holder = payable(msg.sender);
        nft = _nft
    }

    function getListingFee() public view returns (uint256) {
        return listingFee;
    }
}
