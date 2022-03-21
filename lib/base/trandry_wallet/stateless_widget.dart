
import 'package:flutter/material.dart';

import 'package:trandry_wallet/base/bloc_base.dart';
import 'package:trandry_wallet/base/bloc_state_base.dart';
import 'package:trandry_wallet/base/stateless_base.dart';

abstract class TrandryWalletStateless<
  B extends AdvancedBlocBase<E, GlobalState<S>, S>,
  E,
  S> extends StatelessWidgetWithBloc<B, E, S> {

  const TrandryWalletStateless({required B bloc, Key? key}) : super(bloc: bloc, key: key);

  @override
  Widget onError() {
    // TODO: implement onError
    throw UnimplementedError();
  }

  @override
  Widget onLoading() {
    return const Center(child: CircularProgressIndicator(),);
  }

  @override
  void onResult({required BuildContext context, required result}) {
    Navigator.of(context).maybePop(result);
  }

  @override
  void onTokenExpired(BuildContext context) {
    // TODO: implement onTokenExpired
  }

}