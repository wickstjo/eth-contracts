pragma solidity ^0.5.0;

// IMPORT HELPER CONTRACT INTERFACES
import { TaskManager } from './Manager.sol';

contract Task {

    // TASK BUYER & SELLER
    address payable public buyer;
    address payable public seller;

    // LOCKED STATUS
    bool public locked = false;

    // TASK PARAMS
    string public name;
    uint public reputation;
    string public encryption;
    uint public reward;

    // TASK MANAGER REFERENCE & LISTED INDEX
    TaskManager public task_manager;
    uint public position;

    // WHEN THE CONTRACT IS CREATED
    constructor(
        address payable _buyer,
        string memory _name,
        uint _reputation,
        string memory _encryption,
        uint _position
    ) public payable {

        // SET TASK OWNER
        buyer = _buyer;

        // SET STATIC TASK PARAMS
        name = _name;
        reputation = _reputation;
        encryption = _encryption;
        reward = msg.value;

        // SET TASK MANAGER REFERENCE & LISTED INDEX
        task_manager = TaskManager(msg.sender);
        position = _position;
    }

    // ACCEPT TASK
    function accept(string memory id) public payable {

        // CONTRACT REFERENCES
        address user_manager = task_manager.user_manager;
        address device_manager = task_manager.device_manager;

        // IF THE TASK IS NOT LOCKED
        // IF TRANSACTION VALUE IS HALF OF REWARD
        // IF THE USER IS REGISTERED
        // IF THE USERS REPUTATION IS EQUAL OR HIGHER THAN THE REQUIREMENT
        // IF THE PERFORMING DEVICE IS REGISTERED
        // IF THE DEVICE IS OWNED BY THE USER
        // IF THE DEVICE IS ACTIVE
        require(!locked, 'task is locked');
        require(msg.value >= reward / 2, 'insufficient funds given');
        require(user_manager.exists(msg.sender), 'you are not a registered user');
        require(user_manager.fetch(msg.sender).reputation() >= reputation, 'not enough reputation');
        require(device_manager.exists(id), 'the device is not registered');
        require(device_manager.fetch(id).owner() == msg.sender, 'you are not the device owner');
        require(device_manager.fetch(id).status(), 'device is not active');

        // SET SELLER & LOCK THE TASK
        seller = msg.sender;
        locked = true;

        // ASSIGN TASK TO THE DEVICE
        device_manager.fetch(id).assign(msg.sender);
    }

    // SUBMIT DATA
    function submit(string memory ipfs) public {

        // CONDITIONS
        require(msg.sender == seller, 'you are not the seller');

        // ADD RESPONSE TO BUYER
        users.fetch(buyer).add(name, ipfs);

        // REMOVE TASK, SEND EVENT & SELF DESTRUCT
        tasks.remove(position);
        selfdestruct(seller);
    }

    // DESTROY THE CONTRACT & PAY PARTICIPANTS
    function release() public {

        // CONDITIONS
        require(msg.sender == buyer, 'You are not the creator');
        require(!locked, 'Task has already been accepted');

        // REMOVE TASK, SEND EVENT & SELF DESTRUCT
        tasks.remove(position);
        selfdestruct(buyer);
    }
}