pragma solidity ^0.6.8;
// SPDX-License-Identifier: MIT

contract User {

    // CURRENT REPUTATION
    uint public reputation = 1;

    // ITERABLE LIST OF TASK RESULTS
    address[] public results;

    // TASK MANAGER REFERENCE
    address task_manager;

    // WHEN CREATED, SET TASK MANAGER REFERENCE
    constructor(address _task_manager) public {
        task_manager = _task_manager;
    }

    // ADD TASK RESULT
    function add_result(address task) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // PUSH TO RESULTS
        results.push(task);
    }

    // INCREASE REPUTATION
    function award(uint amount) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // INCREASE BY AMOUNT
        reputation += amount;
    }
}