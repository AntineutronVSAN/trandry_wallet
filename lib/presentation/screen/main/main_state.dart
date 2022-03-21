import 'package:trandry_wallet/base/bloc_state_base.dart';

class MainState extends BaseState<MainState> {
  final double ethBalance;
  final bool started;
  final int usersCount;
  final double loteryBalance;

  final bool depositButtonLoading;

  MainState({
    required this.ethBalance,
    required this.started,
    required this.loteryBalance,
    required this.usersCount,
    this.depositButtonLoading = false,
  });

  factory MainState.empty() {
    return MainState(
      ethBalance: 0,
      started: false,
      usersCount: 0,
      loteryBalance: 0,
    );
  }

  MainState copyWith({
    ethBalance,
    started,
    usersCount,
    loteryBalance,
    depositButtonLoading,
  }) {
    return MainState(
      ethBalance: ethBalance ?? this.ethBalance,
      started: started ?? this.started,
      usersCount: usersCount ?? this.usersCount,
      loteryBalance: loteryBalance ?? this.loteryBalance,
      depositButtonLoading: depositButtonLoading ?? false,
    );
  }
}
