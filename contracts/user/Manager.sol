pragma solidity ^0.5.0;

// IMPORT INTERFACE
import { User } from './User.sol';

contract UserManager {

    // HASHMAP OF USER CONTRACTS -- [OWNER => LOCATION]
    mapping (address => User) public users;

    // INIT STATUS & TASK MANAGER ADDRESS
    bool initialized = false;
    address task_manager;

    // CHECK IF USER EXISTS
    function exists(address user) public view returns(bool) {
        if (address(users[user]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }

    // FETCH USER
    function fetch(address user) public view returns(User) {

        // IF THE USER EXISTS
        require(exists(user), 'user does not exist');
        return users[user];
    }

    // ADD ENTRY TO HASHMAP
    function add(string memory nickname) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE USER DOES NOT EXIST
        require(initialized, 'contract has not been initialized');
        require(!exists(msg.sender), 'user already exists');

        // PUSH ENTRY TO HASHMAP
        users[msg.sender] = new User(nickname, task_manager);
    }

    // INITIALIZE CONTRACT
    function init(address _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCES
        task_manager = _task_manager;

        // BLOCK FURTHER MODIFICATION
        initialized = true;
    }
}