pragma solidity ^0.6.8;
// SPDX-License-Identifier: MIT

// IMPORT INTERFACE
import { Task } from './Task.sol';
import { UserManager } from '../user/Manager.sol';
import { DeviceManager } from '../device/Manager.sol';
import { TokenManager } from '../Token.sol';

contract TaskManager {

    // MAP OF ALL TASKS, [ADDRESS => INTERFACE]
    mapping (address => Task) tasks;

    // MAP OF ALL TASK RESULTS, [ADDRESS => STRUCT]
    mapping (address => result) results;

    // ITERABLE LIST OF OPEN TASKS
    Task[] public open;

    // TASK RESULT PARAMS
    struct result {
        string key;         // PUBLIC ENCRYPTION KEY
        string ipfs;        // IPFS QN-HASH
    }

    // TOKEN FEE FOR TASK CREATION
    uint public fee;

    // INIT STATUS & MANAGER REFERENCES
    bool initialized = false;
    UserManager user_manager;
    DeviceManager device_manager;
    TokenManager token_manager;

    // FETCH TASK BY ADDRESS
    function fetch_task(address task) public view returns(Task) {
        return tasks[task];
    }

    // FETCH TASK BY ADDRESS
    function fetch_result(address task) public view returns(result) {
        return results[task];
    }

    // ADD NEW TASK
    function add(
        uint reputation,
        uint reward,
        string memory encryption_key,
        uint timelimit
    ) public {

        // IF CONTRACT HAS BEEN INITIALIZED
        // SENDER IS A REGISTERED USER
        // USER HAS ENOUGH TOKENS
        require(initialized, 'contracts have not been initialized');
        require(user_manager.exists(msg.sender), 'you need to be registered');
        require(token_manager.balance(msg.sender) >= reward + fee, 'insufficient tokens');

        // INSTANTIATE NEW TASK
        Task task = new Task(
            msg.sender,
            reputation,
            reward,
            encryption_key,
            timelimit
        );

        // ADD IT TO BOTH CONTAINERS
        tasks[address(task)] = task;
        open.push(task);

        // CONSUME TOKEN FEE FROM THE CREATOR
        token_manager.consume(fee, msg.sender);

        // TRANSFER THE REWARD TOKENS TO THE TASK MANAGER
        token_manager.transfer(reward, msg.sender, address(this));
    }

    // ACCEPT TASK
    function accept(
        address _task,
        string memory _device
    ) public {

        // IF THE TASK EXISTS
        // IF THE DEVICE EXISTS
        require(exists(_task), 'task does not exist');
        require(device_manager.exists(_device), 'device does not exist');

        // TASK & DEVICE SHORTHANDS
        Task task = fetch(_task);

        // IF THE TASK IS NOT LOCKED
        // IF THE USER IS REGISTERED
        // IF THE USER HAS ENOUGH REPUTATION
        // IF THE SENDER HAS ENOUGH TOKENS
        // IF THE SENDER IS THE DEVICE OWNER
        require(!task.locked(), 'task is locked');
        require(user_manager.exists(msg.sender), 'you need to be registered');
        require(user_manager.fetch(msg.sender).reputation() >= task.reputation(), 'not enough reputation');
        require(token_manager.balance(msg.sender) >= task.reward() / 2, 'insufficient tokens');
        require(device_manager.fetch_device(_device).owner() == msg.sender, 'you are not the device owner');

        // ASSIGN TASK TO THE DELIVERER & DEVICE
        task.assign(msg.sender, _device);
        device_manager.fetch_device(_device).assign_task(_task);

        // TRANSFER TOKENS TO TASK MANAGER & UNLIST TASK FROM OPEN
        token_manager.transfer(task.reward() / 2, msg.sender, address(this));
        unlist(_task);
    }

    // COMPLETE TASK BY SUBMITTING RESULT
    function complete(
        address _task,
        string memory _key,
        string memory _data
    ) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND FOR TASK
        Task task = fetch(_task);

        // IF THE SENDER IS THE DELIVERER
        require(task.deliverer() == msg.sender, 'you are not the deliverer');

        // CONSTRUCT & PUSH NEW RESULT
        results[_task] = result({
            key: _key,
            ipfs: _ipfs
        });

        // ADD REFERENCE TO THE TASK CREATOR
        user_manager.fetch(task.creator()).add_result(_task);

        // REWARD BOTH PARTIES WITH REPUTATION
        user_manager.fetch(task.creator()).award(1);
        user_manager.fetch(msg.sender).award(2);

        // TRANSFER REWARD TOKENS FROM THE TASK MANAGER TO THE DELIVERER
        token_manager.transfer(
            task.reward(),
            address(this),
            msg.sender
        );

        // CLEAR TASK FROM DEVICE BACKLOG
        device_manager.fetch_device(task.device()).clear_task(_task);

        // FINALLY DESTROY THE TASK
        task.destroy();
    }

    // RELEASE THE TASK
    function release(address _task) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND
        Task task = fetch(_task);

        // IF THE SENDER IS THE CREATOR
        require(task.creator() == msg.sender, 'you are not the creator');

        // IF THE TASK IS NOT LOCKED OR THE TIME LIMIT HAS BEEN EXCEEDED
        if (!task.locked() || block.timestamp > task.expires()) {

            // TRANSFER TOKENS FROM TASK MANAGER TO CREATOR
            token_manager.transfer(
                task.reward(),
                address(this),
                msg.sender
            );

            // IF THE TASK IS LISTED, UNLIST IT
            if (!task.locked()) {
                unlist(_task);

            // OTHERWISE, REMOVE TASK FROM DEVICE BACKLOG
            } else {
                device_manager.fetch_device(task.device()).clear_task(_task);
            }

            // DESTROY THE TASK
            task.destroy();
        }
    }

    // SET STATIC VARIABLES
    function init(
        uint _fee,
        address _user_manager,
        address _device_manager,
        address _token_manager
    ) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET TASK TOKEN FEE
        fee = _fee;

        // SET REFERENCES
        user_manager = UserManager(_user_manager);
        device_manager = DeviceManager(_device_manager);
        token_manager = TokenManager(_token_manager);

        // BLOCK FURTHER MODIFICATION
        initialized = true;
    }

    // CHECK IF TASK EXISTS
    function exists(address _task) public view returns(bool) {
        if (address(tasks[_task]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }

    // UNLIST TASK FROM OPEN
    function unlist(address target) private {
        for(uint index = 0; index < open.length; index++) {
            if (address(open[index]) == target) {
                delete open[index];
            }
        }
    }
}