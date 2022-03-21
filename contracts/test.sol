pragma solidity >=0.4.22 <0.9.0;

contract TestLotery {
    uint public number;

    struct TestStruct {
        string field1;
        bool field2;
    }

    // Местная хеша-таблица
    mapping(uint => TestStruct) public testMap;

    event TaskCreated(string task, uint number);

    constructor() public {
        number = 0;
    }

    function createTask(string memory taskName) public {
        testMap[number++] = TestStruct(taskName, false);

        emit TaskCreated(taskName, number-1);

    }


}
