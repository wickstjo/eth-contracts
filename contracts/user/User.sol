pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import { UserManager } from './Manager.sol';

contract User {

    // NICKNAME & CURRENT REPUTATION STATUS
    string public nickname;
    uint public reputation;

    // USER MANAGER REFERENCE
    UserManager user_manager;

    // HASHMAP OF TASK RESPONSES -- [TASK LOCATION => RESPONSE DATA]
    mapping (address => data) public tasks;

    // TASK DATA STRUCT
    struct data {
        string key;
        string ipfs;
    }

    // WHEN CREATED
    constructor(string memory _nickname, UserManager _user_manager) public {

        // SET NICKNAME & DEFAULT REPUTATION
        nickname = _nickname;
        reputation = 0;

        // SET USER MANAGER REFERENCE
        user_manager = _user_manager;
    }

    // ADD TASK RESULT
    function add_task(string memory _key, string memory _ipfs) public {

        // IF SENDER IS THE TASK MANAGER CONTRACT
        require(msg.sender == user_manager.task_manager, 'permission denied');

        // PUSH ENTRY TO HASHMAP
        tasks[msg.sender] = data({
            key: _key,
            ipfs: _ipfs
        });
    }

    // FETCH TASK RESULT
    function fetch_task(address location) public view returns (data memory) {
        return tasks[location];
    }
}