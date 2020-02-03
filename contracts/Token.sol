pragma solidity ^0.5.0;

contract TokenManager {

    // MAP OF TOKEN OWNERSHIP, [ETH USER => AMOUNT]
    mapping (address => uint) public tokens;

    // TOKEN PRICE
    uint public token_price;

    // INIT STATUS & TASK MANAGER REFERENCE
    bool initialized = false;
    address task_manager;

    // FETCH USER BALANCE
    function balance(address user) public view returns(uint) {
        return tokens[user];
    }

    // BUY TOKENS
    function buy(uint amount) public payable {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE SENDER HAS SUFFICIENT FUNDS
        require(initialized, 'contract has not been initialized');
        require(msg.value == amount * token_price, 'insufficient funds');

        // INCREASE TOKEN COUNT FOR SENDER
        tokens[msg.sender] += amount;
    }

    // SELL TOKENS
    function sell(uint amount) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE USER HAS ENOUGH TOKENS
        require(initialized, 'contract has not been initialized');
        require(balance(msg.sender) >= amount, 'not enough tokens');

        // DECREASE TOKEN COUNT FOR USER
        tokens[msg.sender] -= amount;

        // TRANSFER ETH
        msg.sender.transfer(amount * token_price);
    }

    // CONSUME TOKENS
    function consume(uint amount, address user) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE USER HAS SUFFICIENT FUNDS
        // IF THE CALLER IS THE TASK MANAGER CONTRACT
        require(initialized, 'contract has not been initialized');
        require(msg.sender == task_manager, 'you cannot call this method');

        // DECREASE TOKEN COUNT FOR USER
        tokens[user] -= amount;
    }

    // TRANSFER TOKENS BETWEEN USERS
    function transfer(uint amount, address from, address to) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE SENDER HAS ENOUGH TOKENS TO TRANSFER
        require(initialized, 'contract has not been initialized');
        require(msg.sender == task_manager, 'you cannot call this method');

        // REDUCE TOKENS FROM SENDER, THEN INCREASE THEM FOR USER
        tokens[from] -= amount;
        tokens[to] += amount;
    }

    // INITIALIZE
    function init(uint _token_price, address _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED BEFORE
        require(!initialized, 'contract has already been initialized');

        // SET PRICE & TASK MANAGER REFERENCE
        token_price = _token_price;
        task_manager = _task_manager;

        // BLOCK FURTHER MODIFICATIONS
        initialized = true;
    }
}