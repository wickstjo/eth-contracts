pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

// IMPORT INTERFACES
import { Device } from './Device.sol';
import { UserManager } from '../user/Manager.sol';

contract DeviceManager {

    // UNIQUE DEVICES, [DEVICE_ID => DEVICE CONTRACT]
    mapping (string => Device) devices;

    // USER DEVICE COLLECTION, [ETH USER => ARRAY OF DEVICE_ID]
    mapping (address => string[]) collections;

    // INIT STATUS
    bool initialized = false;

    // REFERENCES
    UserManager user_manager;
    address task_manager;

    // CHECK IF DEVICE EXISTS
    function exists(string memory _hash) public view returns(bool) {
        if (address(devices[_hash]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }

    // CHECK IF USER IS DEVICE OWNER
    function is_owner(string memory device_id, address sender) public view returns(bool) {
        if (exists(device_id) && devices[device_id].owner() == sender) {
            return true;
        } else {
            return false;
        }
    }

    // ADD DEVICE
    function add_device(string memory device_id, string memory name) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE DEVICE DOES NOT EXIST
        // IF THE USER IS REGISTERED
        require(initialized, 'contract has not been initialized');
        require(!exists(device_id), 'device already exist');
        require(user_manager.exists(msg.sender), 'you are not a registered user');

        // PUSH NEW ENTRY TO BOTH HASHMAPS
        devices[device_id] = new Device(msg.sender, name, task_manager);
        collections[msg.sender].push(device_id);
    }

    // FETCH SPECIFIC DEVICE
    function fetch_device(string memory id) public view returns(Device) {

        // IF THE DEVICE EXISTS
        require(exists(id), 'device does not exist');
        return devices[id];
    }

    // FETCH USER COLLECTION
    function fetch_collection(address user) public view returns(string[] memory) {
        return collections[user];
    }

    // INITIALIZE
    function init(UserManager _user_manager, address _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED BEFORE
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCES
        user_manager = _user_manager;
        task_manager = _task_manager;

        // BLOCK FURTHER MODIFICATIONS
        initialized = true;
    }
}