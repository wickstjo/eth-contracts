pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract User {

    // NAME & CURRENT REPUTATION
    string public name;
    uint public reputation = 1;

    // MAP OF COMPLETED TASKS -- [TASK ADDRESS => TASK REPORT]
    mapping (address => task_report) public results;

    // ITERABLE ARRAY OF ALL TASK RESULTS
    address[] public task_results;

    // TASK REPORT OBJECT
    struct task_report {
        string key;         // DEVICE GENERATED PUBLIC KEY FOR DECRYPTION
        string ipfs;        // IPFS QM HASH
    }

    // TASK MANAGER REFERENCE
    address task_manager;

    // WHEN CREATED, SET NICKNAME & TASK MANAGER ADDRESS
    constructor(
        string memory _name,
        address _task_manager
    ) public {
        name = _name;
        task_manager = _task_manager;
    }

    // ADD TASK RESULT
    function add_result(string memory _key, string memory _ipfs) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // PUSH ENTRY TO HASHMAP
        results[msg.sender] = task_report({
            key: _key,
            ipfs: _ipfs
        });

        // PSUH TO COMPLETED
        task_results.push(msg.sender);
    }

    // FETCH ALL TASK RESULTS
    function fetch_all() public view returns(address[] memory) {
        return task_results;
    }

    // FETCH SPECIFIC TASK RESULT
    function fetch_result(address task) public view returns (task_report memory) {
        return results[task];
    }

    // REWARD REPUTATION
    function reward(uint amount) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // INCREASE BY AMOUNT
        reputation += amount;
    }
}