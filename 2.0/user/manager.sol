pragma solidity ^0.6.8;
// SPDX-License-Identifier: MIT

// IMPORT INTERFACE
import { User } from './User.sol';

contract UserManager {

    // MAP OF ALL USERS, [ADDRESS => INTERFACE]
    mapping (address => User) public users;

    // ITERABLE LIST OF USERS
    address[] public everyone;

    // INIT STATUS & TASK MANAGER REFERENCE
    bool initialized = false;
    address task_manager;

    // FETCH USER CONTRACT
    function fetch(address user) public view returns(User) {
        return users[user];
    }

    // ADD NEW USER
    function add() public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE USER DOES NOT EXIST
        require(initialized, 'contract has not been initialized');
        require(!exists(msg.sender), 'address is already registered');

        // PUSH ENTRY TO BOTH CONTAINERS
        users[msg.sender] = new User(task_manager);
        everyone.push(msg.sender);
    }

    // SET STATIC VARIABLES
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