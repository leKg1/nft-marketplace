//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract ListingPrice {
    /**
     * @dev The fee charged by the marketplace to be allowed to list an NFT
     */
    uint256 listPrice = 0.01 ether;

    /**
     * @dev owner The address that created the smart contract
     */
    address payable owner;

    /**
     * @dev The event emitted when listing price changes
     */
    event ListingPriceChanged(uint newPrice, uint256 timestamp);

    /**
     * @dev Update the fee allowed to list an NFT to the marketplace
     * @param _listPrice The new fee to list an NFT to the marketplace
     */
    function updateListPrice(uint256 _listPrice) public payable {
        require(owner == msg.sender, "Only owner can update listing price");
        listPrice = _listPrice;

        emit ListingPriceChanged(_listPrice, block.timestamp);
    }

    /**
     * @dev get the fee allowed to list an NFT to the marketplace
     */
    function getListPrice() public view returns (uint256) {
        return listPrice;
    }
}