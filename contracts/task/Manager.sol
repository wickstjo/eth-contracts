pragma solidity ^0.5.0;

// IMPORT INTERFACES
import { Task } from './Task.sol';
import { UserManager } from '../user/Manager.sol';
import { DeviceManager } from '../device/Manager.sol';
import { TokenManager } from '../Token.sol';

contract TaskManager {

    // OPEN TASKS
    Task[] public tasks;

    // INIT STATUS
    bool public initialized = false;

    // REFERENCES
    UserManager user_manager;
    DeviceManager device_manager;
    TokenManager token_manager;

    // ADD TASK
    function add(
        string memory name,
        uint reputation,
        string memory encryption
    ) public payable {

        // IF CONTRACT HAS BEEN INITIALIZED
        // SENDER IS A REGISTERED USER
        // USER HAS ENOUGH TOKENS
        require(initialized, 'contracts have not been initialized');
        require(user_manager.exists(msg.sender), 'you are not a registered user');
        require(token_manager.balance(msg.sender) >= 1, 'you do not have the tokens to do this');

        // REMOVE A TOKEN FROM SENDER
        token_manager.remove(1, msg.sender);

        // INSTANTIATE NEW TASK
        Task task = (new Task).value(msg.value)(
            msg.sender,
            name,
            reputation,
            encryption,
            tasks.length
        );

        // LIST IT
        tasks.push(task);
    }

    // REMOVE TASK
    function remove(uint index) public {

        // IF THE CALLER IS THE TASK CONTRACT ITSELF
        require(tasks[index] == Task(msg.sender), 'you are not permitted to call this');
        delete tasks[index];
    }

    // INITIALIZE CONTRACT
    function init(
        UserManager _user_manager,
        DeviceManager _device_manager,
        TokenManager _token_manager
    ) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCES
        user_manager = _user_manager;
        device_manager = _device_manager;
        token_manager = _token_manager;

        // BLOCK FURTHER MODIFICATION
        initialized = true;
    }
}