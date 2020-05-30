pragma solidity ^0.5.0;

contract Task {

    // TASK CREATOR, DELIVERER & PERFORMING DEVICE
    address public creator;
    address public deliverer;
    address public device;

    // DETAILS
    bool public locked = false;
    uint public reputation;
    uint public reward;
    string public encryption_key;
    uint256 public expires;

    // TASK MANAGER REFERENCE
    address task_manager;

    // WHEN CREATED
    constructor(
        address _creator,
        uint _reputation,
        uint _reward,
        string memory _encryption_key,
        uint timelimit
    ) public {

        // TASK DETAILS
        creator = _creator;
        reputation = _reputation;
        reward = _reward;
        encryption_key = _encryption_key;
        expires = block.timestamp + timelimit;

        // TASK MANAGER REFERENCE
        task_manager = msg.sender;
    }

    // ACCEPT TASK
    function assign(
        address _deliverer,
        string memory _device
    ) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // SET SELLER & LOCK THE TASK
        deliverer = _deliverer;
        locked = true;

        // SET PERFORMING DEVICE & INCREASE THE REWARD
        device = _device;
        reward += reward / 2;
    }

    // SELF DESTRUCT
    function destroy() public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');
        selfdestruct(address(uint160(address(this))));
    }
}