pragma solidity ^0.5.0;

contract Device {

    // DEVICE PARAMS
    address payable public owner;
    string name;

    // LATEST ASSIGNED TASK
    address[] public assignments;

    // ACTIVE STATUS
    bool public active = true;

    // NEW ASSIGNMENT EVENT
    event Update(address task);

    // WHEN CREATED, SET DEFAULT PARAMS
    constructor(
        address payable _owner,
        string memory _name
    ) public {
        owner = _owner;
        name = _name;
    }

    // TOGGLE CONTRACT STATUS
    function toggle() public {

        // IF CALLER IS THE DEVICE OWNER
        require(msg.sender == owner, 'you are not the owner');
        active = !active;
    }

    // ASSIGN TASK TO DEVICE
    function assign(address payable sender) public {

        // IF SENDER IS THE DEVICE OWNER
        // IF THE DEVICE IS ACTIVE
        require(sender == owner, 'you are not the owner');
        require(active, 'device is inactive');

        // PUSH ASSIGNMENT & EMIT EVENT
        assignments.push(msg.sender);
        emit Update(msg.sender);
    }
}