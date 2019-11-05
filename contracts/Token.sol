pragma solidity ^0.5.0;

contract TokenManager {

    // HASHMAP OF TOKEN OWNERSHIP, [USER ADDRESS => AMOUNT]
    mapping (address => uint) public tokens;

    // TOKEN PRICE
    uint public price;

    // INIT STATUS
    bool initialized = false;

    // TASK MANAGER REFERENCE
    address task_manager;

    // FETCH USER BALANCE
    function balance(address user) public view returns(uint) {
        return tokens[user];
    }

    // ADD TOKEN
    function add(uint amount) public payable {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE SENDER HAS SUFFICIENT FUNDS
        require(initialized, 'contract has not been initialized');
        require(msg.value == amount * price, 'insufficient funds');

        // INCREASE TOKEN COUNT FOR SENDER
        tokens[msg.sender] += amount;
    }

    // REMOVE TOKEN
    function remove(uint amount, address user) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE USER HAS SUFFICIENT FUNDS
        // IF THE CALLER IS THE TASK MANAGER CONTRACT
        require(initialized, 'contract has not been initialized');
        require(tokens[user] >= amount, 'user token count exceeded');
        require(msg.sender == task_manager, 'you cannot call this method');

        // DECREASE TOKEN COUNT FOR USER
        tokens[user] -= amount;
    }

    // TRANSFER TOKENS FROM SENDER TO USER
    function transfer(uint amount, address user) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE SENDER HAS ENOUGH TOKENS TO TRANSFER
        require(initialized, 'contract has not been initialized');
        require(tokens[msg.sender] >= amount, 'user token count exceeded');

        // REDUCE TOKENS FROM SENDER, THEN INCREASE THEM FOR USER
        tokens[msg.sender] -= amount;
        tokens[user] += amount;
    }

    // INITIALIZE
    function init(uint _price, address _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED BEFORE
        require(!initialized, 'contract has already been initialized');

        // SET PRICE & TASK MANAGER REFERENCE
        price = _price;
        task_manager = _task_manager;

        // BLOCK FURTHER MODIFICATIONS
        initialized = true;
    }
}