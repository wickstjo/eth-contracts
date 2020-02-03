pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract User {

    // NAME & CURRENT REPUTATION
    uint public reputation = 1;

    // MAP OF COMPLETED TASKS -- [TASK ADDRESS => TASK REPORT]
    mapping (address => task_report) public results;

    // ITERABLE ARRAY OF ALL COMPLETED TASK RESULTS
    address[] public task_results;

    // TASK REPORT OBJECT
    struct task_report {
        string key;         // DEVICE GENERATED PUBLIC KEY FOR DECRYPTION
        string data;        // ENCRYPTED DATA
    }

    // TASK MANAGER REFERENCE
    address task_manager;

    // WHEN CREATED, SET TASK MANAGER ADDRESS
    constructor(address _task_manager) public {
        task_manager = _task_manager;
    }

    // FETCH ALL TASK RESULTS
    function fetch_all() public view returns(address[] memory) {
        return task_results;
    }

    // FETCH SPECIFIC TASK RESULT
    function fetch_result(address task) public view returns (task_report memory) {
        return results[task];
    }

    // ADD TASK RESULT
    function add_result(
        string memory _key,
        string memory _data
    ) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // PUSH ENTRY TO HASHMAP
        results[msg.sender] = task_report({
            key: _key,
            data: _data
        });

        // PUSH TO COMPLETED
        task_results.push(msg.sender);
    }

    // REWARD REPUTATION
    function reward(uint amount) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // INCREASE BY AMOUNT
        reputation += amount;
    }
}