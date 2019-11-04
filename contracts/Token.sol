pragma solidity ^0.5.0;

contract TokenManager {

    // INIT STATUS & TASK MANAGER LOCATION
    bool public initialized = false;
    address public task_manager;

    // HASHMAP OF TOKEN OWNERS, [OWNER => AMOUNT]
    mapping (address => uint) public tokens;

    // TOKEN PRICE
    uint public price;

    // BALANCE CHANGE EVENT
    event Update(address user, uint amount);

    // INITIALIZE PARAMS
    function init(uint _price, address _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED BEFORE
        require(!initialized, 'contract has already been initialized');

        // SET PRICE & TASK MANAGER LOCATION
        price = _price;
        task_manager = _task_manager;

        // BLOCK FURTHER MODIFICATIONS
        initialized = true;
    }

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

        // EMIT EVENT
        emit Update(msg.sender, tokens[msg.sender]);
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

        // SEND EVENT
        emit Update(user, tokens[user]);
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

        // EMIT EVENT FOR BOTH USERS
        emit Update(msg.sender, tokens[msg.sender]);
        emit Update(user, tokens[user]);
    }
}