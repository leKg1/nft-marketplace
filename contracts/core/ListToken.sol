//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ListingPrice.sol";

abstract contract ListToken is ERC721URIStorage, ListingPrice {

    using Counters for Counters.Counter;
    
    /**
     * @dev _tokenIds This variable has the most recent minted tokenId
     */
    Counters.Counter internal _tokenIds;

    /**
     * @dev The structure to store info about a listed token
     */
    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    /**
     * @dev The event emitted when a token is successfully listed
     */
    event TokenListedSuccess (
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool currentlyListed
    );

    /**
     * @dev This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId
     */
    mapping(uint256 => ListedToken) internal _idToListedToken;

    /**
     * @dev Return the info about the latest listed token
     */
    function getLatestIdToListedToken() public view returns (ListedToken memory) {
        uint256 currentTokenId = _tokenIds.current();
        return _idToListedToken[currentTokenId];
    }

    /**
     * @dev Return the info about the given token id
     */
    function getListedTokenForId(uint256 tokenId) public view returns (ListedToken memory) {
        return _idToListedToken[tokenId];
    }

    /**
     * @dev Return the current token id
     */
    function getCurrentToken() public view returns (uint256) {
        return _tokenIds.current();
    }

    /**
     * @dev Create new token
     * @param tokenURI The link to the file
     * @param price The price of the NFT
     */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        //Increment the tokenId counter, which is keeping track of the number of minted NFTs
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        //Mint the NFT with tokenId newTokenId to the address who called createToken
        _safeMint(msg.sender, newTokenId);

        //Map the tokenId to the tokenURI (which is an IPFS URL with the NFT metadata)
        _setTokenURI(newTokenId, tokenURI);

        //Helper function to update Global variables and emit an event
        createListedToken(newTokenId, price);

        return newTokenId;
    }

    /**
     * @dev To add the new created token to our mapping and transfer the ownership to the smart contract(so no approval needed later to transfer)
     * @param tokenId The new token id
     * @param price The price of the NFT
     */ 
    function createListedToken(uint256 tokenId, uint256 price) private {
        //Make sure the sender sent enough ETH to pay for listing
        require(msg.value == listPrice, "Hopefully sending the correct price");
        //Just sanity check
        require(price > 0, "Make sure the price isn't negative");

        //Update the mapping of tokenId's to Token details, useful for retrieval functions
        _idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );

        //Transfer the ownership to the smart contract
        _transfer(msg.sender, address(this), tokenId);
        
        //Emit the event for successful transfer. The frontend parses this message and updates the end user
        emit TokenListedSuccess(
            tokenId,
            address(this),
            msg.sender,
            price,
            true
        );
    }
}