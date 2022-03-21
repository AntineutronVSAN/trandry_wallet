pragma solidity >=0.4.22 <0.9.0;

contract FlutterLotery {

    // -----------------------
    bool public started;
    int public usersCount;
    uint public totalMoney;

    // -----------------------
    // Все, кто вложил средства в лотерею
    mapping(address => uint) public balances;


    // -----------------------
    event StartedEvent();
    event EndedEvent();
    event BalanceChangedEvent(uint newBalance);
    event NewMemberEvent();

    constructor() public {
        started = false;
        usersCount = 0;
        totalMoney = 0;
    }

    //Положить на депозит эфир
    function deposit() public payable {

        // TODO Потом тут нужно выставить минимум
        if (msg.value <= 0) {
            return;
        }

        if (balances[msg.sender] == 0) {
            if (started) {
                addNewMember();
            }
        }

        balances[msg.sender] += msg.value;
        totalMoney += msg.value;
        emit BalanceChangedEvent(totalMoney);

        if (!started) {
            started = true;
            emit StartedEvent();
            addNewMember();
            return;
        }

    }

    // Получить текущий баланс лотереи
    function getLoteryBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Узнать, сколько средств на счету
    function getDepositValue() public returns (uint) {
        return balances[msg.sender];
    }

    // -------------------
    function addNewMember() private {
        usersCount++;
        emit NewMemberEvent();
    }

    // Запущена ли лотерея
    //bool public started;
    // Есть ли банк
    //bool private hasBankAddr;

    // Сколько участников
    //int public usersCount;
    // Сколько денег в банке
    //int private totalMoney;

    //event MessageSended(address sender, int256 value);
    //event TestEvent(uint value);

    //mapping(address => uint) public balances;


    // Модель участника
    //struct LoteryUser {
    //    string userName;
    //    int payment;
    //    address addr;
    //}

    // Адрес банка, где хранятся средства
    //address private bankAddress;

    //event Deposit(address sender, uint amount);
    //event Withdrawal(address receiver, uint amount);

//    constructor() public {
//        started = false;
//        usersCount = 0;
//        hasBankAddr = false;
//        totalMoney = 0;
//    }

    /// Изменить адрес банка средств. Стоит подумать, как защититься от того, что любой може тсделать себя банком
//    function setBankAddress(address bankAddr) public { // memory - копирует объект и он будет уничтожен после выхода из ф-ии?
//        bankAddress = bankAddr;
//        hasBankAddr = true;
//    }

    // Отправить эфир по адресу _to. Отправляет вызывающий функцию
//    function testSender(address _to) public payable {

        //int256 val = msg.value;

        //(bool sent, bytes memory data) = _to.call{value: msg.value}("");
//        (bool success, ) = _to.call.value(msg.value)("");
//        //emit TestEvent(100);
//        require(success, "Failed to send Ether");
//        //emit MessageSended(msg.sender, msg.value);
//        emit MessageSended(msg.sender, 254);
//    }

//    function getBalance() public view returns (uint) {
//        return address(this).balance;
//    }

    // Положить на депозит эфир
//    function deposit() public payable {
//        emit Deposit(msg.sender, msg.value);
//        balances[msg.sender] += msg.value;
//    }

    // Снять с депозита эфир
//    function withdraw(uint amount) public {
//        require(balances[msg.sender] >= amount, "Insufficient funds");
//        emit Withdrawal(msg.sender, amount);
//        balances[msg.sender] -= amount;
//        // Главная функция отправляющая эфир обратно
//        msg.sender.transfer(amount);
//    }

}
