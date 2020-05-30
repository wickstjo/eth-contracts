pragma solidity ^0.6.8;
// SPDX-License-Identifier: MIT

// IMPORT INTERFACE
import { Task } from './Task.sol';
import { UserManager } from '../user/Manager.sol';
import { DeviceManager } from '../device/Manager.sol';
import { TokenManager } from '../Token.sol';

contract TaskManager {

    // MAP OF ALL TASKS, [ADDRESS => INTERFACE]
    mapping (address => Task) tasks;

    // ITERABLE LIST OF OPEN TASKS
    Task[] public open;

    // TOKEN FEE FOR TASK CREATION
    uint public fee;

    // INIT STATUS & MANAGER REFERENCES
    bool initialized = false;
    UserManager user_manager;
    DeviceManager device_manager;
    TokenManager token_manager;

    // FETCH TASK BY ADDRESS
    function fetch(address task) public view returns(Task) {
        return tasks[task];
    }
}