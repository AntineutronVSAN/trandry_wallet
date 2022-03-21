import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:trandry_wallet/presentation/screen/main/main_bloc.dart';
import 'package:trandry_wallet/presentation/screen/main/main_event.dart';
import 'package:trandry_wallet/presentation/screen/main/main_state.dart';

import 'package:trandry_wallet/base/trandry_wallet/stateless_widget.dart';
import 'package:trandry_wallet/theme/button.dart';

class MainScreen
    extends TrandryWalletStateless<MainBloc, MainEvent, MainState> {
  const MainScreen({required MainBloc bloc, Key? key})
      : super(bloc: bloc, key: key);

  @override
  void onListen(MainState newState, BuildContext context) {
    // TODO: implement onListen
  }

  @override
  Widget onStateLoaded(MainState newState, BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: Colors.green,
            child: Text('Ваш эфир - ${newState.ethBalance} ETH'),
          ),
          Container(
            color: Colors.green,
            child: Text('Эфир лотереи - ${newState.loteryBalance} ETH'),
          ),
          Container(
            color: Colors.green,
            child: Text('Участников - ${newState.usersCount}'),
          ),
          Container(
            color: Colors.green,
            child: Text('Стартовала - ${newState.started}'),
          ),
          const SizedBox(
            height: 25,
          ),
          ThemeButtons.getThemeButton(
            text: 'Пополнить 1 ETH',
            onPressed: () => addEvent(event: MainScreenDeposit1ETHEvent()),
            loading: newState.depositButtonLoading,
          ),
        ],
      ),
    ));
  }
}
