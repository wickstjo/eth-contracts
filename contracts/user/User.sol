pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract User {

    // NICKNAME & CURRENT REPUTATION STATUS
    string public nickname;
    uint public reputation;

    // HASHMAP OF TASK RESPONSES -- [TASK LOCATION => RESPONSE DATA]
    mapping (address => data) public tasks;

    // TASK DATA STRUCT
    struct data {
        string key;
        string ipfs;
    }

    // WHEN CREATED, SET NICKNAME & DEFAULT REPUTATION
    constructor(string memory _nickname) public {
        nickname = _nickname;
        reputation = 0;
    }

    // ADD TASK RESULT
    function add_task(string memory _key, string memory _ipfs) public {
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