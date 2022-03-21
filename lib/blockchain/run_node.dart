

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import 'contracts/lotery_adapter.dart';

/*

IDE Solidity
https://remix.ethereum.org/

truffle migrate --reset
dart compile exe lib\blockchain\run_node.dart


*/

void main() async {

  const String prcUrlConst = 'http://127.0.0.1:7545';
  const String wsUrlConst = 'ws://127.0.0.1:7545';

  const String senderPrivateKey =
      '477cbac4aaf84c607602aad482ce73eee09d830a56cf589071df2599345ca2fe';

  Web3Client client = Web3Client(prcUrlConst, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(wsUrlConst).cast<String>();
  });
  final file = File(r'D:\flutter_projects\trandry_wallet\src\abis\FlutterLotery.json');

  final mainLoteryObject = LoteryAdapter(
      client: client,
      abiData: await file.readAsString(),
      privateKey: senderPrivateKey
  );

  await mainLoteryObject.init();

  final count = await mainLoteryObject.getUsersCount();
  final started = await mainLoteryObject.loteryStarted();

  print('Статус лотерии. Число участников - $count');
  print('Статус лотерии. Стартовала - $started');

  //await mainLoteryObject.callTestSenderFunc();

  //print('Пополнение депозита');
  //await mainLoteryObject.depositFunc(1);
  print('Снятие с депозита');
  await mainLoteryObject.withdrawFunc(1000000000000000000);

  final result = await mainLoteryObject.getLoteryBalance();
  print('Текущий баланс (баланс кого? Похоже,'
      ' что это баланс контракта) равен - $result');

  await mainLoteryObject.dispose();







  /*Credentials credentials = await client.credentialsFromPrivateKey(senderPrivateKey);

  EthereumAddress ownAddress = await credentials.extractAddress();
  EthereumAddress recieverAddress = EthereumAddress.fromHex(
      '0xA0CB442E7b7830DeD944Ea6694CB3a25d9d3Fc47');*/

  //print(ownAddress);

  /*await client.sendTransaction(credentials, Transaction(
      from: ownAddress,
      to: recieverAddress,
    value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
  ));*/


  //final jsonData = rootBundle.loadString('asfd');
  /*final data = File(r'D:\flutter_projects\trandry_wallet\src\abis\TestLotery.json');
  final contents = await data.readAsString();
  final jsonData = jsonDecode(contents);


  final abiCode = json.encode(jsonData['abi']);
  final addr = jsonData['networks']['5777']['address'];

  EthereumAddress contractAddress = EthereumAddress.fromHex(addr);

  DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'TestLotery'),
      contractAddress
  );

  ContractFunction numberFunc = contract.function('number');
  ContractFunction testMap = contract.function('testMap');
  ContractFunction createTask = contract.function('createTask');

  ContractEvent event = contract.event('TaskCreated');
  final subscription = client
      .events(
      FilterOptions.events(contract: contract, event: event))
      //.take(0)
      .listen((e) {
    //final decoded = event.decodeResults(event.topics, event.data);
    print('asdfasdfasdfasdfasdfasdfasdf----------------');
    //print(event.topics);
    print(event.decodeResults(e.topics!, e.data!));
    print('asdfasdfasdfasdfasdfasdfasdf----------------');
  });

  List nums = await client.call(
      contract: contract,
      function: numberFunc,
      params: []
  );

  BigInt tasks = nums[0];
  print(tasks);
  print('----');
  for(var i=0; i<tasks.toInt(); i++) {
    List mapValues = await client.call(
        contract: contract,
        function: testMap,
        params: [BigInt.from(i)]
    );
    print(mapValues[0]);
  }
  print('----');
  /// Если нужно изменять состояние блокчейна - используем client.sendTransaction
  /// Если не нужно изменять состояние блокчейна - используем client.call
  *//*await client.sendTransaction(credentials, Transaction.callContract(
      contract: contract,
      function: createTask,
      parameters: ['My test function 3']));
  await client.sendTransaction(credentials, Transaction.callContract(
      contract: contract,
      function: createTask,
      parameters: ['My test function 5']));*//*



  print('1');*/
}


