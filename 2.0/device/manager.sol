pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

// IMPORT INTERFACE
import { Device } from './Device.sol';
import { UserManager } from '../user/Manager.sol';

contract DeviceManager {

    // MAP OF ALL DEVICES, [DEVICE ID => INTERFACE]
    mapping (string => Device) devices;

    // USER DEVICE COLLECTIONS, [ADDRESS => LIST OF DEVIVES]
    mapping (address => string[]) collections;

    // INIT STATUS & MANAGER REFERENCE
    bool initialized = false;
    UserManager user_manager;
    address task_manager;

    // FETCH DEVICE CONTRACT
    function fetch_device(string memory id) public view returns(Device) {
        return devices[id];
    }

    // FETCH USER DEVICE COLLECTION
    function fetch_collection(address user) public view returns(string[] memory) {
        return collections[user];
    }

    // ADD NEW DEVICE
    function add(
        string memory id,
        string memory name
    ) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE DEVICE DOES NOT EXIST
        // IF THE USER IS REGISTERED
        require(initialized, 'contract has not been initialized');
        require(!exists(id), 'identifier already exists');
        require(user_manager.exists(msg.sender), 'you need to be a registered user');

        // INSTATIATE NEW DEVICE & ADD IT
        devices[id] = new Device(
            msg.sender,
            name,
            task_manager
        );

        // PUSH INTO USER COLLECTION
        collections[msg.sender].push(id);
    }

    // SET STATIC VARIABLES
    function init(
        address _user_manager,
        address _task_manager
    ) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED BEFORE
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCES
        user_manager = UserManager(_user_manager);
        task_manager = _task_manager;

        // BLOCK FURTHER MODIFICATIONS
        initialized = true;
    }

    // CHECK IF DEVICE EXISTS
    function exists(string memory id) public view returns(bool) {
        if (address(devices[id]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }
}