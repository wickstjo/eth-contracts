pragma solidity ^0.5.0;

// IMPORT USER INTERFACE
import { User } from './User.sol';
import { TaskManager } from '../task/Manager.sol';

contract UserManager {

    // HASHMAP OF USER CONTRACTS -- [OWNER => LOCATION]
    mapping (address => User) public users;

    // TASK MANAGER REFERENCE & INIT STATUS
    TaskManager task_manager;
    bool initialized = false;

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

        // FETCH DETAILS
        return users[user];
    }

    // ADD ENTRY TO HASHMAP
    function add(string memory nickname) public {

        // IF THE USER DOES NOT EXIST
        require(!exists(msg.sender), 'user already exists');

        // PUSH ENTRY TO HASHMAP
        users[msg.sender] = new User(nickname, address(this));
    }

    // INITIALIZE CONTRACT
    function init(TaskManager _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCES
        task_manager = _task_manager;

        // BLOCK FURTHER MODIFICATION
        initialized = true;
    }
}