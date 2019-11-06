pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract User {

    // NAME & CURRENT REPUTATION
    string public name;
    uint public reputation = 0;

    // MAP OF TASK RESULTS -- [TASK LOCATION => RESPONSE DATA]
    mapping (address => data) public results;

    // TASK RESPONSE DATA STRUCT
    struct data {
        string key;         // PUBLIC KEY TO ASYMETRIC ENCRYPTION
        string ipfs;        // IPFS QM HASH
    }

    // USER MANAGER REFERENCE
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
        results[msg.sender] = data({
            key: _key,
            ipfs: _ipfs
        });
    }

    // FETCH TASK RESULT
    function fetch_result(address task) public view returns (data memory) {
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