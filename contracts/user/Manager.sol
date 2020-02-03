pragma solidity ^0.5.0;

// IMPORT INTERFACE
import { User } from './User.sol';

contract UserManager {

    // MAP OF REGISTERED USERS -- [ETH USER => USER CONTRACT]
    mapping (address => User) public users;

    // ITERABLE LIST OF ALL USERS
    address[] everyone;

    // INIT STATUS & TASK MANAGER ADDRESS
    bool initialized = false;
    address task_manager;

    // FETCH ALL USERS
    function fetch_everyone() public view returns(address[] memory) {
        return everyone;
    }

    // FETCH SPECIFIC USER
    function fetch_user(address user) public view returns(User) {
        return users[user];
    }

    // ADD ENTRY TO HASHMAP
    function add() public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE USER DOES NOT EXIST
        require(initialized, 'contract has not been initialized');
        require(!exists(msg.sender), 'user already exists');

        // PUSH ENTRY TO MAP & ARRAY
        users[msg.sender] = new User(task_manager);
        everyone.push(msg.sender);
    }

    // INITIALIZE CONTRACT
    function init(address _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCE & BLOCK FURTHER MODIFICATION
        task_manager = _task_manager;
        initialized = true;
    }

    // CHECK IF USER EXISTS
    function exists(address user) public view returns(bool) {
        if (address(users[user]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }
}