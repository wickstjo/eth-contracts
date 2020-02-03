pragma solidity ^0.5.0;

contract Task {

    // TASK CREATOR, DELIVERER & PERFORMING DEVICE
    address public creator;
    address public deliverer;
    string public device;

    // LOCKED STATUS
    bool public locked = false;

    // DETAILS
    uint public min_reputation;
    uint public reward;
    uint256 public created;
    string public encryption_key;

    // TASK MANAGER REFERENCE
    address task_manager;

    // WHEN CREATED
    constructor(
        address _creator,
        uint _reputation,
        uint _reward,
        string memory _encryption_key
    ) public {

        // TASK DETAILS
        creator = _creator;
        min_reputation = _reputation;
        reward = _reward;
        encryption_key = _encryption_key;
        created = block.timestamp;

        // TASK MANAGER REFERENCE
        task_manager = msg.sender;
    }

    // ACCEPT TASK
    function accept(
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