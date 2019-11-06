pragma solidity ^0.5.0;

// IMPORT INTERFACES
import { Task } from './Task.sol';
import { UserManager } from '../user/Manager.sol';
import { DeviceManager } from '../device/Manager.sol';
import { TokenManager } from '../Token.sol';

contract TaskManager {

    // HASHMAP OF UNIQUE TASKS, [LOCATION => TASK INSTANCE]
    mapping (address => Task) tasks;

    // OPEN TASKS
    Task[] public open;

    // INIT STATUS
    bool initialized = false;

    // REFERENCES
    UserManager user_manager;
    DeviceManager device_manager;
    TokenManager token_manager;

    // CHECK IF TASK EXISTS
    function exists(address _task) public view returns(bool) {
        if (address(tasks[_task]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }

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
            open.length,
            user_manager,
            device_manager
        );

        // ADD HASHMAP ENTRY & LIST IT
        tasks[address(task)] = task;
        open.push(task);
    }

    // UNLIST TASK
    function unlist() public {

        // IF THE TASK EXISTS
        require(exists(msg.sender), 'task does not exist');
        delete open[Task(msg.sender).position()];
    }

    // ACCEPT TASK
    function accept(address _task, string memory _device) public {

        // IF THE TASK EXISTS
        // IF THE DEVICE EXISTS
        require(exists(_task), 'task does not exist');
        require(device_manager.exists(_device), 'device does not exist');
    }

    // SUBMIT RESPONSE DATA TO TASK
    function submit(
        address _task,
        string memory _ipfs,
        string memory _key
    ) public {

        // IF THE TASK EXISTS
        // IF THE SENDER IS THE SELLER
        require(exists(_task), 'task does not exist');
        require(tasks[_task].seller() == msg.sender, 'you are not the seller');
        tasks[_task].submit(_ipfs, _key);
    }

    // INITIALIZE
    function init(
        address _user_manager,
        address _device_manager,
        address _token_manager
    ) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCES
        user_manager = UserManager(_user_manager);
        device_manager = DeviceManager(_device_manager);
        token_manager = TokenManager(_token_manager);

        // BLOCK FURTHER MODIFICATION
        initialized = true;
    }
}