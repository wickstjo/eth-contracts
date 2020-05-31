pragma solidity ^0.6.8;
// SPDX-License-Identifier: MIT

contract TokenManager {

    // MAP OF TOKEN OWNERSHIP, [USER ADDRESS => AMOUNT]
    mapping (address => uint) public tokens;

    // TOKEN PRICE
    uint public price;

    // INIT STATUS & TASK MANAGER REFERENCE
    bool initialized = false;
    address task_manager;

    // FETCH USER TOKEN BALANCE
    function balance(address user) public view returns(uint) {
        return tokens[user];
    }

    // PURCHASE TOKENS
    function purchase(uint amount) public payable {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE SENDER HAS SUFFICIENT FUNDS
        require(initialized, 'contract has not been initialized');
        require(msg.value == amount * price, 'insufficient funds provided');

        // INCREASE TOKEN COUNT FOR SENDER
        tokens[msg.sender] += amount;
    }

    // CONSUME USER TOKENS
    function consume(uint amount, address user) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE CALLER IS THE TASK MANAGER CONTRACT
        require(initialized, 'contract has not been initialized');
        require(msg.sender == task_manager, 'permission denied');

        // DECREASE TOKEN COUNT FOR USER
        tokens[user] -= amount;
    }

    // TRANSFER TOKENS BETWEEN USERS
    function transfer(uint amount, address from, address to) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE SENDER HAS ENOUGH TOKENS TO TRANSFER
        require(initialized, 'contract has not been initialized');
        require(msg.sender == task_manager, 'permission denied');

        // REDUCE TOKENS FROM SENDER, THEN INCREASE THEM FOR USER
        tokens[from] -= amount;
        tokens[to] += amount;
    }

    // SET STATIC VARIABLES
    function init(uint _price, address _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED BEFORE
        require(!initialized, 'contract has already been initialized');

        // SET TOKEN PRICE & TASK MANAGER REFERENCE
        price = _price;
        task_manager = _task_manager;

        // BLOCK FURTHER MODIFICATIONS
        initialized = true;
    }
}