pragma solidity ^0.6.8;
// SPDX-License-Identifier: MIT

contract Task {

    // USER & DEVICE PARAMS
    address public creator;
    address public deliverer;
    string public device;

    // TASK DETAILS
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

        // SET STATIC PARAMS
        creator = _creator;
        reputation = _reputation;
        reward = _reward;
        encryption_key = _encryption_key;
        expires = block.timestamp + timelimit;
        task_manager = msg.sender;
    }

    // ACCEPT TASK
    function assign(
        address _deliverer,
        string memory _device
    ) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // SET DELIVERING USER, PERFORMING DEVICE & LOCK THE TASK
        deliverer = _deliverer;
        device = _device;
        locked = true;

        // ADD THE DELIVERERS TOKEN GUARANTEE TO THE REWARD POT
        reward += reward / 2;
    }

    // SELF DESTRUCT
    function destroy() public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');
        selfdestruct(address(uint160(address(this))));
    }
}