import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:trandry_wallet/blockchain/contracts/lotery_adapter.dart';
import 'package:trandry_wallet/presentation/screen/main/main_screen.dart';
import 'package:trandry_wallet/presentation/tab_navigator.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import 'const.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final loteryContract = getSmartContract();

  runApp(MyApp(smartLoteryContract: await loteryContract,));
}

Future<LoteryAdapter> getSmartContract() async {

  Web3Client client = Web3Client(prcUrlConst, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(wsUrlConst).cast<String>();
  });

  final abiData = await rootBundle.loadString('src/abis/FlutterLotery.json');

  //final file = File(r'D:\flutter_projects\trandry_wallet\src\abis\FlutterLotery.json');

  final mainLoteryObject = LoteryAdapter(
      client: client,
      abiData: abiData,
      privateKey: currentUserPrivateKey
  );

  return mainLoteryObject;
}

class MyApp extends StatelessWidget {

  final LoteryAdapter smartLoteryContract;

  const MyApp({Key? key, required this.smartLoteryContract}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TabNavigator.getMainPage(smartLoteryContract: smartLoteryContract),
    );
  }
}

