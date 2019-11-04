pragma solidity ^0.5.0;

contract Device {

    // DEVICE PARAMS
    address payable public owner;
    string nickname;

    // LATEST ASSIGNED TASK
    address[] public assignments;

    // ACTIVE STATUS
    bool public status;

    // WHEN CREATED, SET DEFAULT PARAMS
    constructor(address payable _owner, string memory _nickname) public {
        owner = _owner;
        nickname = _nickname;
        status = true;
    }

    // NEW ADDED EVENT
    event Update(address task);

    // TOGGLE CONTRACT STATUS
    function toggle() public {

        // IF CALLER IS THE DEVICE OWNER
        require(msg.sender == owner, 'you are not the owner');
        status = !status;
    }

    // ASSIGN TASK TO DEVICE
    function assign(address _task, address payable sender) public {

        // IF SENDER IS THE DEVICE OWNER
        // IF THE DEVICE IS ACTIVE
        require(sender == owner, 'you are not the owner');
        require(status, 'device is out of commission');

        // PUSH ASSIGNMENT & EMIT EVENT
        assignments.push(_task);
        emit Update(_task);
    }
}