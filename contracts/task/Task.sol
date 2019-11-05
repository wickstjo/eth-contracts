pragma solidity ^0.5.0;

// IMPORT INTERFACES
import { TaskManager } from './Manager.sol';
import { DeviceManager } from '../device/Manager.sol';
import { UserManager } from '../user/Manager.sol';

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

    // LISTED INDEX
    uint public position;

    // CONTRACT REFERENCES
    UserManager user_manager;
    DeviceManager device_manager;
    TaskManager task_manager;

    // WHEN THE CONTRACT IS CREATED
    constructor(
        address payable _buyer,
        string memory _name,
        uint _reputation,
        string memory _encryption,
        uint _position,
        UserManager _user_manager,
        DeviceManager _device_manager
    ) public payable {

        // SET TASK OWNER
        buyer = _buyer;

        // SET STATIC TASK PARAMS
        name = _name;
        reputation = _reputation;
        encryption = _encryption;
        reward = msg.value;

        // SET LISTED INDEX
        position = _position;

        // SET CONTRACT REFERENCES
        user_manager = _user_manager;
        device_manager = _device_manager;
        task_manager = TaskManager(msg.sender);
    }

    // ACCEPT TASK
    function accept(string memory id) public payable {

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
        require(device_manager.fetch_device(id).owner() == msg.sender, 'you are not the device owner');
        require(device_manager.fetch_device(id).active(), 'device is not active');

        // SET SELLER & LOCK THE TASK
        seller = msg.sender;
        locked = true;

        // ASSIGN TASK TO THE DEVICE
        device_manager.fetch_device(id).assign(msg.sender);
    }

    // SUBMIT RESPONSE DATA
    function submit(
        string memory ipfs,
        string memory key,
        address proxy
    ) public {

        // IF THE SENDER IS THE TASK MANAGER
        // IF THE SENDER PROXY IS THE SELLER
        require(msg.sender == address(task_manager), 'permission denied');
        require(proxy == seller, 'you are not the seller');

        // ADD RESPONSE TO BUYER
        user_manager.fetch(buyer).add_task(key, ipfs);

        // UNLIST TASK & SELF DESTRUCT
        task_manager.remove(position);
        selfdestruct(seller);
    }

    // DESTROY THE CONTRACT & PAY PARTICIPANTS
    function release() public {

        // IF SENDER IS BUYER
        // IF TASK IS NOT LOCKED
        require(msg.sender == buyer, 'You are not the creator');
        require(!locked, 'The task is locked');

        // REMOVE TASK, SEND EVENT & SELF DESTRUCT
        task_manager.remove(position);
        selfdestruct(buyer);
    }
}