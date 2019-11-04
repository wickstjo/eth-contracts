pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

// IMPORT DEVICE CONTRACT
import { Device } from './Device.sol';
import { UserManager } from '../user/Manager.sol';

contract DeviceManager {

    // UNIQUE DEVICES, [HASH ID => CONTRACT LOCATION]
    mapping (string => Device) devices;

    // USER DEVICE COLLECTION, [USER ADDRESS => LIST OF DEVICE IDS]
    mapping (address => string[]) collections;

    // INIT STATUS
    bool initialized = false;

    // USER MANAGER CONTRACT REFERENCE
    UserManager user_manager;

    // DEVICE ADDED EVENT
    event Update(address user, string[] devices);

    // INITIALIZE CONTRACT
    function init(UserManager _user_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED BEFORE
        require(!initialized, 'contract has already been initialized');

        // SET USER MANAGER REFERENCE
        user_manager = _user_manager;

        // BLOCK FURTHER MODIFICATIONS
        initialized = true;
    }

    // CHECK IF DEVICE EXISTS
    function exists(string memory _hash) public view returns(bool) {
        if (address(devices[_hash]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }

    // CHECK IF USER IS DEVICE OWNER
    function is_owner(string memory _hash, address sender) public view returns(bool) {
        if (exists(_hash) && devices[_hash].owner() == sender) {
            return true;
        } else {
            return false;
        }
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

    // ADD DEVICE
    function add(string memory id, string memory nickname) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE DEVICE DOES NOT EXIST
        // IF THE USER IS REGISTERED
        require(initialized, 'contract has not been initialized');
        require(!exists(id), 'device already exist');
        require(user_manager.exists(msg.sender), 'you are not a registered user');

        // PUSH NEW ENTRY TO BOTH HASHMAPS
        devices[id] = new Device(msg.sender, nickname);
        collections[msg.sender].push(id);

        // EMIT EVENT
        emit Update(msg.sender, collections[msg.sender]);
    }
}