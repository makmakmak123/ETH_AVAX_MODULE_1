// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleBank {
    address public owner;
    uint public itemCounter;

    struct Item {
        uint id;
        string name;
        uint price;
        uint stock;
    }

    mapping(uint => Item) public items;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        itemCounter = 0;
    }

    // Add a new clothing item
    function addItem(string memory name, uint price, uint stock) public onlyOwner {
        require(bytes(name).length > 0, "Item name must be provided");
        require(price > 0, "Item price must be greater than zero");
        require(stock > 0, "Item stock must be greater than zero");

        itemCounter++;
        items[itemCounter] = Item(itemCounter, name, price, stock);

    }

    // Purchase a clothing item
    function purchaseItem(uint id, uint quantity) public payable {
        require(id > 0 && id <= itemCounter, "Item does not exist");
        Item storage item = items[id];
        require(quantity > 0, "Quantity must be greater than zero");
        require(quantity <= item.stock, "Insufficient stock");
        require(msg.value >= item.price * quantity, "Insufficient funds");

        item.stock -= quantity;

        // Refund any excess payment
        if (msg.value > item.price * quantity) {
            payable(msg.sender).transfer(msg.value - item.price * quantity);
        }

        // Ensure the item stock is never negative
        assert(item.stock >= 0);
    }

    // Check the stock of an item
    function checkStock(uint id) public view returns (uint) {
        require(id > 0 && id <= itemCounter, "Item does not exist");
        return items[id].stock;
    }

    // Transfer ownership to a new owner
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero");
        owner = newOwner;
    }

    // Update item details
    function updateItem(uint id, string memory name, uint price, uint stock) public onlyOwner {
        require(id > 0 && id <= itemCounter, "Item does not exist");
        require(bytes(name).length > 0, "Item name must be provided");
        require(price > 0, "Item price must be greater than zero");
        require(stock >= 0, "Item stock cannot be negative");

        Item storage item = items[id];
        item.name = name;
        item.price = price;
        item.stock = stock;

        // Revert if the stock goes negative (just as an extra safeguard)
        if (item.stock < 0) {
            revert("Item stock cannot be negative");
        }
    }
}
