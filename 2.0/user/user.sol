pragma solidity ^0.6.8;
// SPDX-License-Identifier: MIT

contract User {

    // CURRENT REPUTATION
    uint public reputation = 1;

    // ITERABLE LIST OF TASK RESULTS
    result[] public results;

    // TASK RESULT PARAMS
    struct result {
        address task;       // TASK ADDRESS
        string key;         // PUBLIC ENCRYPTION KEY
        string ipfs;        // IPFS QN-HASH
    }

    // TASK MANAGER REFERENCE
    address task_manager;

    // WHEN CREATED, SET TASK MANAGER REFERENCE
    constructor(address _task_manager) public {
        task_manager = _task_manager;
    }

    // ADD TASK RESULT
    function add_result(
        address _task,
        string memory _key,
        string memory _ipfs
    ) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // CONSTRUCT RESULT STRUCT
        result memory temp = result({
            task: _task,
            key: _key,
            ipfs: _ipfs
        });

        // PUSH TO RESULTS
        results.push(temp);
    }

    // INCREASE REPUTATION
    function award(uint amount) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // INCREASE BY AMOUNT
        reputation += amount;
    }
}