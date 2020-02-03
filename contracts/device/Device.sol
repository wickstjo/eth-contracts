pragma solidity ^0.5.0;

contract Device {

    // PROPERTIES
    address public owner;
    string public name;

    // TASK BACKLOG
    address[] public backlog;

    // TASK MANAGER REFERENCE
    address task_manager;

    // NEW ASSIGNMENT EVENT
    event Update(address[] backlog);

    // WHEN CREATED
    constructor(
        address _owner,
        string memory _name,
        address _task_manager
    ) public {

        // SET BASIC PROPERTIES
        owner = _owner;
        name = _name;

        // SET TASK MANAGER REFERENCE
        task_manager = _task_manager;
    }

    // FETCH ASSIGNMENT BACKLOG
    function fetch_backlog() public view returns(address[] memory) {
        return backlog;
    }

    // ASSIGN TASK TO DEVICE
    function assign_task(address _task) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // PUSH ASSIGNMENT & EMIT EVENT
        backlog.push(_task);
        emit Update(backlog);
    }

    // CLEAR TASK FROM BACKLOG
    function unlist_task(address target) public {

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