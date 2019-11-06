pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract User {

    // NICKNAME & CURRENT REPUTATION
    string public name;
    uint public reputation = 0;

    // HASHMAP OF TASK RESPONSES -- [TASK LOCATION => RESPONSE DATA]
    mapping (address => data) public responses;

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
    function add_response(string memory _key, string memory _ipfs) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // PUSH ENTRY TO HASHMAP
        responses[msg.sender] = data({
            key: _key,
            ipfs: _ipfs
        });

        // INCREASE THE USERS REPUTATION BY ONE
        reputation += 1;
    }

    // FETCH TASK RESULT
    function fetch_response(address task) public view returns (data memory) {
        return responses[task];
    }
}