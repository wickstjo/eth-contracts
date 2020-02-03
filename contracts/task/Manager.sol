pragma solidity ^0.5.0;

// IMPORT INTERFACES
import { Task } from './Task.sol';
import { UserManager } from '../user/Manager.sol';
import { DeviceManager } from '../device/Manager.sol';
import { TokenManager } from '../Token.sol';

contract TaskManager {

    // MAP OF UNIQUE TASKS, [TASK ADDRESS => TASK CONTRACT]
    mapping (address => Task) tasks;

    // ALL CURRENTLY OPEN TASKS
    Task[] public open;

    // TIME LIMIT FOR TASK
    uint limit = 5000;

    // REFERENCES
    UserManager user_manager;
    DeviceManager device_manager;
    TokenManager token_manager;

    // INIT STATUS
    bool initialized = false;

    // FETCH ALL OPEN TASKS
    function fetch_open() public view returns(Task[] memory) {
        return open;
    }

    // FETCH SPECIFIC TASK
    function fetch_task(address task) public view returns(Task) {
        return tasks[task];
    }

    // ADD TASK
    function add_task(
        uint reputation,
        uint reward,
        string memory encryption_key
    ) public {

        // IF CONTRACT HAS BEEN INITIALIZED
        // SENDER IS A REGISTERED USER
        // USER HAS ENOUGH TOKENS
        require(initialized, 'contracts have not been initialized');
        require(user_manager.exists(msg.sender), 'you are not a registered user');
        require(token_manager.balance(msg.sender) >= reward + 1, 'insufficient tokens');

        // INSTANTIATE NEW TASK
        Task task = new Task(
            msg.sender,
            reputation,
            reward,
            encryption_key
        );

        // ADD IT TO BOTH LISTS
        tasks[address(task)] = task;
        open.push(task);

        // CONSUME ONE TOKEN FOR CREATION
        token_manager.consume(reward, msg.sender);

        // TRANSFER THE REWARD TOKENS TO THE TASK MANAGER
        token_manager.transfer(reward, msg.sender, address(this));
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

        // SHORTHAND FOR TASK
        Task task = fetch_task(_task);

        // IF THE TASK IS NOT LOCKED
        // IF THE USER IS REGISTERED
        // IF THE USER HAS ENOUGH REPUTATION
        // IF THE SENDER HAS ENOUGH TOKENS
        // IF THE SENDER IS THE DEVICE OWNER
        require(!task.locked(), 'task is locked');
        require(user_manager.exists(msg.sender), 'you are not a registered user');
        require(user_manager.fetch_user(msg.sender).reputation() >= task.min_reputation(), 'not enough reputation');
        require(token_manager.balance(msg.sender) >= task.reward() / 2, 'insufficient funds given');
        require(device_manager.fetch_device(_device).owner() == msg.sender, 'you are not the device owner');

        // ACCEPT THE TASK & ASSIGN IT TO THE DEVICE
        task.accept(msg.sender, _device);
        device_manager.fetch_device(_device).assign_task(_task);

        // UNLIST TASK FROM OPEN & TRANSFER TOKENS TO TASK MANAGER
        unlist(_task);
        token_manager.transfer(task.reward() / 2, msg.sender, address(this));
    }

    // SUBMIT TASK RESULT
    function submit_result(
        address _task,
        string memory _key,
        string memory _data
    ) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND FOR TASK
        Task task = fetch_task(_task);

        // IF THE SENDER IS THE SELLER
        require(task.deliverer() == msg.sender, 'you are not the deliverer');

        // SEND THE RESULT TO THE TASK CREATORS USER CONTRACT
        user_manager.fetch_user(task.creator()).add_result(_key, _data);

        // REWARD BOTH PARTIES WITH REPUTATION
        user_manager.fetch_user(task.creator()).reward(1);
        user_manager.fetch_user(msg.sender).reward(2);

        // TRANSFER REWARD TOKENS TO THE SENDER
        token_manager.transfer(
            task.reward(),
            address(this),
            msg.sender
        );

        // UNLIST FROM OPEN & DEVICE BACKLOG
        unlist(_task);
        device_manager.fetch_device(task.device()).unlist_task(_task);

        // FINALLY DESTROY THE TASK
        task.destroy();
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

            // TRANSFER TOKENS FROM TASK MANAGER TO SENDER
            token_manager.transfer(
                task.reward(),
                address(this),
                msg.sender
            );

            // IF THE TASK IS LISTED, UNLIST IT
            if (!task.locked()) {
                unlist(_task);

            // OTHERWISE, REMOVE FROM DEVICE BACKLOG
            } else {
                device_manager.fetch_device(task.device()).unlist_task(_task);
            }

            // DESTROY THE TASK
            task.destroy();
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