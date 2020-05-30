pragma solidity ^0.6.8;
// SPDX-License-Identifier: MIT

contract Device {

    // PROPERTIES
    address public owner;
    string public name;

    // ITERABLE TASK BACKLOG
    address[] public backlog;

    // NEW ASSIGNMENT EVENT
    event Assignment(address[] backlog);

    // TASK MANAGER REFERENCE
    address task_manager;

    // SET STATIC VARIABLES
    constructor(
        address _owner,
        string memory _name,
        address _task_manager
    ) public {

        // SET PROPERTIES
        owner = _owner;
        name = _name;
        task_manager = _task_manager;
    }

    // ASSIGN TASK TO DEVICE
    function assign_task(address _task) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // ADD TASK TO BACKLOG & TRIGGER EVENT
        backlog.push(_task);
        emit Assignment(backlog);
    }

    // CLEAR FINISHED TASK FROM BACKLOG
    function clear_task(address target) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // LOOP, FIND & DELETE TARGET
        for(uint index = 0; index < backlog.length; index++) {
            if (address(backlog[index]) == target) {
                delete backlog[index];
            }
        }
    }
}