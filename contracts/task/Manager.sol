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

    // TIME LIMIT FOR TASK
    uint limit = 5000;

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
        require(token_manager.balance(msg.sender) >= 1, 'not enough tokens');

        // REMOVE A TOKEN FROM SENDER
        token_manager.remove(1, msg.sender);

        // INSTANTIATE NEW TASK
        Task task = (new Task).value(msg.value)(
            msg.sender,
            name,
            reputation,
            encryption,
            open.length
        );

        // ADD HASHMAP ENTRY & LIST IT
        tasks[address(task)] = task;
        open.push(task);
    }

    // FETCH TASK
    function fetch(address _task) public view returns(Task) {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');
        return tasks[_task];
    }

    // ACCEPT TASK
    function accept(
        address _task,
        string memory _device
    ) public payable {

        // IF THE TASK EXISTS
        // IF THE DEVICE EXISTS
        require(exists(_task), 'task does not exist');
        require(device_manager.exists(_device), 'device does not exist');

        // SHORTHAND
        Task task = fetch(_task);

        // IF THE TASK IS NOT LOCKED
        require(!task.locked(), 'task is locked');
        require(msg.value >= task.reward() / 2, 'insufficient funds given');

        // IF THE USER IS REGISTERED
        // IF THE USER HAS ENOUGH REPUTATION
        require(user_manager.exists(msg.sender), 'you are not a registered user');
        require(user_manager.fetch(msg.sender).reputation() >= task.reputation(), 'not enough reputation');

        // IF THE SENDER IS THE DEVICE OWNER
        // IF THE DEVICE IS ACTIVE
        require(device_manager.fetch_device(_device).owner() == msg.sender, 'you are not the device owner');
        require(device_manager.fetch_device(_device).active(), 'device is not active');

        // ACCEPT THE TASK & FORWARD THE FUNDS
        task.accept.value(msg.value)(msg.sender);

        // ASSIGN TASK TO THE DEVICE
        device_manager.fetch_device(_device).assign(_task);
    }

    // SUBMIT TASK RESULT
    function submit(
        address _task,
        string memory _ipfs,
        string memory _key
    ) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND
        Task task = fetch(_task);

        // IF THE SENDER IS THE SELLER
        require(task.seller() == msg.sender, 'you are not the seller');

        // SEND THE RESULT TO THE BUYERS USER CONTRACT
        user_manager.fetch(task.buyer()).add_result(_key, _ipfs);

        // REWARD BOTH PARTIES WITH REPUTATION
        user_manager.fetch(task.buyer()).reward(1);
        user_manager.fetch(msg.sender).reward(2);

        // UNLIST & DESTROY THE TASK
        delete open[task.index()];
        task.complete();
    }

    // RELEASE THE TASK
    function release(address _task) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND
        Task task = fetch(_task);

        // IF THE SENDER IS THE BUYER
        require(task.buyer() == msg.sender, 'you are not the buyer');

        // IF THE TASK IS LOCKED & THE TIME LIMIT HAS NOT BEEN EXCEEDED
        if (task.locked() && block.timestamp < task.created() + limit) {

            // UNLIST & DESTROY THE TASK
            delete open[task.index()];
            task.release();
        }
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