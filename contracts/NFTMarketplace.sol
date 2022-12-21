//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./libraries/ListingPrice.sol";
import "./libraries/ListToken.sol";
import "./libraries/GetNFTs.sol";

contract NFTMarketplace is ListingPrice, ListToken, GetNFTs {

    /**
     * @dev Keeps track of the number of items sold on the marketplace
     */
    Counters.Counter private _itemsSold;

    constructor() ERC721("LeKgNFTMarketplace", "LKNFTM") {
        owner = payable(msg.sender);
    }

    function executeSale(uint256 tokenId) public payable {
        uint price = _idToListedToken[tokenId].price;
        address seller = _idToListedToken[tokenId].seller;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        //update the details of the token
        _idToListedToken[tokenId].currentlyListed = true;
        _idToListedToken[tokenId].seller = payable(msg.sender);
        _itemsSold.increment();

        //Actually transfer the token to the new seller
        _transfer(address(this), msg.sender, tokenId);
        //approve the marketplace to sell NFTs on your behalf
        approve(address(this), tokenId);

        //Transfer the listing fee to the marketplace creator
        payable(owner).transfer(listPrice);
        //Transfer the proceeds from the sale to the seller of the NFT
        payable(seller).transfer(msg.value);
    }

    //We might add a resell token function in the future
    //In that case, tokens won't be listed by default but users can send a request to actually list a token
    //Currently NFTs are listed by default
}