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

    // TASK MANAGER REFERENCE
    address task_manager;

    // WHEN CREATED
    constructor(
        address _creator,
        uint _reputation,
        uint _reward
    ) public {

        // TASK DETAILS
        creator = _creator;
        min_reputation = _reputation;
        reward = _reward;
        created = block.timestamp;

        // TASK MANAGER REFERENCE
        task_manager = msg.sender;
    }

    // ACCEPT TASK
    function accept_task(
        address payable _deliverer,
        string memory _device,
        uint _index
    ) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // SET SELLER & LOCK THE TASK
        deliverer = _deliverer;
        locked = true;

        // SET PERFORMING DEVICE & LISTED INDEX
        device = _device;
        device_index = _index;
    }

    // UNLOCK TASK
    function unlock_task() public {

        // IF THE SENDER IS THE SELLER
        require(msg.sender == deliverer, 'permission denied');

        // UNLOCK THE TASK & RESET SELLER
        locked = false;
        deliverer = 0x0000000000000000000000000000000000000000;

        // TRANSFER 25% OF THE REWARD BACK
        deliverer.transfer(reward / 4);
    }

    // COMPLETE THE TASK
    function complete_task() public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // SELF DESTRUCT & TRANSFER FUNDS TO THE SELLER
        selfdestruct(deliverer);
    }

    // RELEASE THE TASK
    function release_task() public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // SELF DESTRUCT & TRANSFER FUNDS TO THE BUYER
        selfdestruct(creator);
    }
}