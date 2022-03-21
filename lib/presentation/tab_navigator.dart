

import 'package:flutter/cupertino.dart';
import 'package:trandry_wallet/base/bloc_state_base.dart';
import 'package:trandry_wallet/blockchain/contracts/lotery_adapter.dart';
import 'package:trandry_wallet/presentation/screen/main/main_bloc.dart';
import 'package:trandry_wallet/presentation/screen/main/main_event.dart';
import 'package:trandry_wallet/presentation/screen/main/main_screen.dart';
import 'package:trandry_wallet/presentation/screen/main/main_state.dart';


class TabNavigator {

  static Widget getMainPage({required LoteryAdapter smartLoteryContract}) {

    final bloc = MainBloc(MainState.empty().toContent(), smartLoteryContract: smartLoteryContract)..add(MainInitialEvent());
    final mainPage = MainScreen(bloc: bloc);

    return mainPage;
  }


}