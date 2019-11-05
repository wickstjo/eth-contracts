pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract User {

    // NICKNAME & CURRENT REPUTATION
    string public nickname;
    uint public reputation = 0;

    // HASHMAP OF TASK RESPONSES -- [TASK LOCATION => RESPONSE DATA]
    mapping (address => data) public tasks;

    // TASK RESPONSE DATA STRUCT
    struct data {
        string key;         // PUBLIC KEY TO ASYMETRIC ENCRYPTION
        string ipfs;        // IPFS QM HASH
    }

    // USER MANAGER REFERENCE
    address task_manager;

    // WHEN CREATED, SET NICKNAME & TASK MANAGER ADDRESS
    constructor(
        string memory _nickname,
        address _task_manager
    ) public {
        nickname = _nickname;
        task_manager = _task_manager;
    }

    // ADD TASK RESULT
    function add_task(string memory _key, string memory _ipfs) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // PUSH ENTRY TO HASHMAP
        tasks[msg.sender] = data({
            key: _key,
            ipfs: _ipfs
        });
    }

    // FETCH TASK RESULT
    function fetch_task(address location) public view returns (data memory) {
        return tasks[location];
    }
}