pragma solidity ^0.5.0;

contract Device {

    // DEVICE PARAMS
    address payable public owner;
    string nickname;

    // LATEST ASSIGNED TASK
    address[] public assignments;

    // ACTIVE STATUS
    bool public active;

    // WHEN CREATED, SET DEFAULT PARAMS
    constructor(address payable _owner, string memory _nickname) public {
        owner = _owner;
        nickname = _nickname;
        active = true;
    }

    // NEW ADDED EVENT
    event Update(address task);

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