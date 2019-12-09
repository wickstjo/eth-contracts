pragma solidity ^0.5.0;

// IMPORT INTERFACES
import { Task } from './Task.sol';
import { UserManager } from '../user/Manager.sol';
import { DeviceManager } from '../device/Manager.sol';

contract TaskManager {

    // MAP OF UNIQUE TASKS, [TASK ADDRESS => TASK CONTRACT]
    mapping (address => Task) tasks;

    // ALL CURRENTLY OPEN TASKS
    Task[] public open_tasks;

    // TIME LIMIT FOR TASK
    uint limit = 5000;

    // INIT STATUS
    bool initialized = false;

    // REFERENCES
    UserManager user_manager;
    DeviceManager device_manager;

    // CHECK IF TASK EXISTS
    function exists(address _task) public view returns(bool) {
        if (address(tasks[_task]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }

    // FETCH ALL OPEN TASKS
    function fetch_open() public view returns(Task[] memory) {
        return open_tasks;
    }

    // FETCH TASK
    function fetch_task(address _task) public view returns(Task) {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');
        return tasks[_task];
    }

    // ADD TASK
    function add_task(
        string memory name,
        uint reputation,
        string memory encryption
    ) public payable {

        // IF CONTRACT HAS BEEN INITIALIZED
        // SENDER IS A REGISTERED USER
        // USER HAS ENOUGH TOKENS
        require(initialized, 'contracts have not been initialized');
        require(user_manager.exists(msg.sender), 'you are not a registered user');

        // INSTANTIATE NEW TASK
        Task task = (new Task).value(msg.value)(
            msg.sender,
            name,
            reputation,
            encryption,
            open_tasks.length
        );

        // ADD HASHMAP ENTRY & LIST IT
        tasks[address(task)] = task;
        open_tasks.push(task);
    }

    // ACCEPT TASK
    function accept_task(
        address _task,
        string memory _device
    ) public payable {

        // IF THE TASK EXISTS
        // IF THE DEVICE EXISTS
        require(exists(_task), 'task does not exist');
        require(device_manager.exists(_device), 'device does not exist');

        // SHORTHAND
        Task task = fetch_task(_task);

        // IF THE TASK IS NOT LOCKED
        require(!task.locked(), 'task is locked');
        require(msg.value >= task.reward() / 2, 'insufficient funds given');

        // IF THE USER IS REGISTERED
        // IF THE USER HAS ENOUGH REPUTATION
        require(user_manager.exists(msg.sender), 'you are not a registered user');
        require(user_manager.fetch_user(msg.sender).reputation() >= task.min_reputation(), 'not enough reputation');

        // IF THE SENDER IS THE DEVICE OWNER
        require(device_manager.fetch_device(_device).owner() == msg.sender, 'you are not the device owner');

        // CURRENT ASSIGNMENT BACKLOG LENGTH
        uint length = device_manager.fetch_device(_device).fetch_backlog().length;

        // ACCEPT THE TASK & FORWARD THE FUNDS
        task.accept_task.value(msg.value)(msg.sender, _device, length);

        // ASSIGN TASK TO THE DEVICE
        device_manager.fetch_device(_device).assign_task(_task);
    }

    // SUBMIT TASK RESULT
    function submit_result(
        address _task,
        string memory _ipfs,
        string memory _key
    ) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND
        Task task = fetch_task(_task);

        // IF THE SENDER IS THE SELLER
        require(task.deliverer() == msg.sender, 'you are not the deliverer');

        // SEND THE RESULT TO THE BUYERS USER CONTRACT
        user_manager.fetch_user(task.creator()).add_result(_key, _ipfs);

        // REWARD BOTH PARTIES WITH REPUTATION
        user_manager.fetch_user(task.creator()).reward(1);
        user_manager.fetch_user(msg.sender).reward(2);

        // UNLIST FROM OPEN TASKS & DEVICE BACKLOG
        delete open_tasks[task.task_index()];
        device_manager.fetch_device(task.device()).clear_task(task.device_index());

        // SELF DESTRUCT TASK
        task.complete_task();
    }

    // RELEASE THE TASK
    function release_task(address _task) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND
        Task task = fetch_task(_task);

        // IF THE SENDER IS THE BUYER
        require(task.creator() == msg.sender, 'you are not the creator');

        // IF THE TASK IS LOCKED OR THE TIME LIMIT HAS BEEN EXCEEDED
        if (!task.locked() || block.timestamp > task.created() + limit) {

            // UNLIST & DESTROY THE TASK
            delete open_tasks[task.task_index()];
            task.release_task();

            // IF THE TIME LIMIT WAS EXCEEDE
            if (block.timestamp > task.created() + limit) {

                // UNLIST FROM DEVICE BACKLOG
                device_manager.fetch_device(task.device()).clear_task(task.device_index());
            }
        }
    }

    // INITIALIZE
    function init(
        address _user_manager,
        address _device_manager
    ) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCES
        user_manager = UserManager(_user_manager);
        device_manager = DeviceManager(_device_manager);

        // BLOCK FURTHER MODIFICATION
        initialized = true;
    }
}