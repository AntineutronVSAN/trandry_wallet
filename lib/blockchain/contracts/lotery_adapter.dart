/*

События отрабатывают только если используется send transaction

*/

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:trandry_wallet/blockchain/utils/converters.dart';
import 'package:web3dart/web3dart.dart';

/* Общие ключи контрактов */
const String abiKeyString = 'abi';
const String networksKeyString = 'networks';
const String networkIdKeyString = '5777';
const String networkAddressKeyString = 'address';

/* Специфичные для конкретного контракта */
const String contractName = 'FlutterLotery';

const balanceChangedEventKeyConst = 'BalanceChangedEvent';

class LoteryAdapter {
  final Web3Client client;
  final String abiData;
  final String privateKey;

  bool inited = false;

  late final Credentials credentials;

  late final EthereumAddress contractAddress;
  late final DeployedContract contract;

  /* Поля контракта */
  /// Запущена ли лотерея
  late final ContractFunction _started;
  /// Число участников
  late final ContractFunction _usersCount;
  /// Банк лотереи
  late final ContractFunction _totalMoney;

  /* Функции контракта */
  late final ContractFunction _getLoteryBalance;
  late final ContractFunction _depositFunction;

  /* События */
  final _contractEvents = <String, ContractEventAdapter>{};


  LoteryAdapter(
      {required this.client, required this.abiData, required this.privateKey});

  Future<void> dispose() async {
    for(var i in _contractEvents.values) {
      await i.eventSubscription.cancel();
    }

    await client.dispose();
  }

  Future<void> init() async {
    if (inited) return;

    credentials = await client.credentialsFromPrivateKey(privateKey);

    final contents = abiData;
    final jsonData = jsonDecode(contents);

    final abiCode = json.encode(jsonData[abiKeyString]);
    final addr = jsonData[networksKeyString][networkIdKeyString]
        [networkAddressKeyString];

    contractAddress = EthereumAddress.fromHex(addr);

    contract = DeployedContract(
        ContractAbi.fromJson(abiCode, contractName), contractAddress);

    _started = contract.function('started');
    _usersCount = contract.function('usersCount');
    _totalMoney = contract.function('totalMoney');

    _getLoteryBalance = contract.function('getLoteryBalance');
    _depositFunction = contract.function('deposit');

    // --------- Событие - изменение банка средств лотереи
    _registerNewEvent(balanceChangedEventKeyConst);

    inited = true;
  }

  void subscribeToEvent(String event, Function(List<dynamic>) handler) {
    final hasEvent = _contractEvents.containsKey(event);
    if (!hasEvent) {
      throw Exception('Contract event $event not existst');
    }
    _contractEvents[event]!.handlers.add(handler);
  }

  void _registerNewEvent(String eventName) {
    final hasEvent = _contractEvents.containsKey(eventName);
    if (hasEvent) {
      throw Exception('Event already exists');
    }
    final event = contract.event(eventName);
    final List<Function(List<dynamic>)> newEventHandlers = [];
    final subscription = client
        .events(FilterOptions.events(
        contract: contract, event: event))
        .listen((e) {
      final res = event.decodeResults(e.topics!, e.data!);
      for(var i in newEventHandlers) {
        i(res);
      }
    });
    final adapter = ContractEventAdapter(
        event: event,
        handlers: newEventHandlers,
        eventName: eventName,
        eventSubscription: subscription);
    _contractEvents[eventName] = adapter;
  }

  /// Получить эфирный баланс текущего юзера
  Future<double> getCurrentUserBalance() async {
    final result = await client.getBalance(await credentials.extractAddress());
    final value = result.getInWei;
    return CryptoMoneyConverter.wei2doubleWithDecimals(wei: value);
  }

  /* Публичные поля контракта */
  Future<int> getUsersCount() async {
    List result = await client
        .call(contract: contract, function: _usersCount, params: []);
    BigInt count = result[0];
    return count.toInt();
  }

  Future<double> getLoteryBalance() async {
    final res = await client
        .call(contract: contract, function: _getLoteryBalance, params: []);
    BigInt result = res[0];
    return CryptoMoneyConverter.wei2doubleWithDecimals(wei: result);
  }

  Future<bool> loteryStarted() async {
    List result =
        await client.call(contract: contract, function: _started, params: []);
    bool count = result[0];
    return count;
  }

  /* Функции контракта */
  Future<void> callTestSenderFunc() async {
    // var result = await client.sendTransaction(
    //     credentials, Transaction.callContract(
    //     contract: contract,
    //     function: testSender,
    //     parameters: [
    //       EthereumAddress.fromHex('0xbb861df40B20083B315F06ff85085Ed203D1A22E'), // todo
    //     ],
    //     value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
    //   )
    // );
    // print('Test sender payable called. Returns value - $result');
  }

  /// Положить на свой счёт контракта value эфира
  Future<void> depositFunc(int value) async {
    var result = await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: _depositFunction,
          parameters: [],
          value: EtherAmount.fromUnitAndValue(EtherUnit.ether, value),
        ));
  }

  /// Снять с депозита сумму value
  Future<void> withdrawFunc(int value) async {
    // var result = await client.sendTransaction(
    //     credentials, Transaction.callContract(
    //     contract: contract,
    //     function: withdraw,
    //     parameters: [BigInt.from(value)],
    //   )
    // );
  }

/* События контракта */

}

class ContractEventAdapter {
  final ContractEvent event;
  final StreamSubscription<FilterEvent> eventSubscription;
  final String eventName;
  final List<Function(List<dynamic>)> handlers;

  ContractEventAdapter(
      {required this.event,
      required this.handlers,
      required this.eventName,
      required this.eventSubscription});
}
