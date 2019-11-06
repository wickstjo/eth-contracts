pragma solidity ^0.5.0;

contract Device {

    // PROPERTIES
    address payable public owner;
    string public name;

    // ASSIGNMENT BACKLOG
    address[] public assignments;

    // ACTIVE STATUS
    bool public active = true;

    // TASK MANAGER REFERENCE
    address task_manager;

    // NEW ASSIGNMENT EVENT
    event Update(address[] assignments);

    // WHEN CREATED
    constructor(
        address payable _owner,
        string memory _name,
        address _task_manager
    ) public {

        // SET BASIC PROPERTIES
        owner = _owner;
        name = _name;

        // SET TASK MANAGER REFERENCE
        task_manager = _task_manager;
    }

    // TOGGLE CONTRACT STATUS
    function toggle() public {

        // IF CALLER IS THE DEVICE OWNER
        require(msg.sender == owner, 'you are not the owner');
        active = !active;
    }

    // ASSIGN TASK TO DEVICE
    function assign(address _task) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // PUSH ASSIGNMENT & EMIT EVENT
        assignments.push(_task);
        emit Update(assignments);
    }
}