pragma solidity ^0.5.0;

contract Task {

    // BUYER & SELLER
    address payable public buyer;
    address payable public seller;

    // LOCKED STATUS
    bool public locked = false;

    // SPECIFICATIONS
    string public name;
    uint public reputation;
    string public encryption;
    uint public reward;

    // CREATED TIMESTAMP
    uint256 public created;

    // TASK MANAGER REFERENCE
    address task_manager;

    // ASSIGNED DEVICE & RELEVANT INDEXES
    string public device;
    uint public task_index;
    uint public device_index;

    // WHEN CREATED
    constructor(
        address payable _buyer,
        string memory _name,
        uint _reputation,
        string memory _encryption,
        uint _index
    ) public payable {

        // SET TASK OWNER
        buyer = _buyer;

        // SET STATIC TASK PARAMS
        name = _name;
        reputation = _reputation;
        encryption = _encryption;
        reward = msg.value;

        // SET LISTED TASK INDEX & CREATED TIMESTAMP
        task_index = _index;
        created = block.timestamp;

        // TASK MANAGER REFERENCE
        task_manager = msg.sender;
    }

    // ACCEPT TASK
    function accept(
        address payable _seller,
        string memory _device,
        uint _index
    ) public payable {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // SET SELLER & LOCK THE TASK
        seller = _seller;
        locked = true;

        // SET PERFORMING DEVICE & LISTED INDEX
        device = _device;
        device_index = _index;
    }

    // UNLOCK TASK
    function unlock() public {

        // IF THE SENDER IS THE SELLER
        require(msg.sender == seller, 'permission denied');

        // UNLOCK THE TASK & RESET SELLER
        locked = false;
        seller = 0x0000000000000000000000000000000000000000;

        // TRANSFER 25% OF THE REWARD BACK
        seller.transfer(reward / 4);
    }

    // COMPLETE THE TASK
    function complete() public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // SELF DESTRUCT & TRANSFER FUNDS TO THE SELLER
        selfdestruct(seller);
    }

    // RELEASE THE TASK
    function release() public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // SELF DESTRUCT & TRANSFER FUNDS TO THE BUYER
        selfdestruct(buyer);
    }
}