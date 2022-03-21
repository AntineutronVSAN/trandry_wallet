

import 'package:bloc/src/bloc.dart';
import 'package:trandry_wallet/base/bloc_base.dart';
import 'package:trandry_wallet/base/bloc_state_base.dart';
import 'package:trandry_wallet/presentation/screen/main/main_event.dart';
import 'package:trandry_wallet/blockchain/contracts/lotery_adapter.dart';
import 'package:trandry_wallet/presentation/screen/main/main_state.dart';



class MainBloc extends AdvancedBlocBase<MainEvent, GlobalState<MainState>, MainState> {

  final LoteryAdapter smartLoteryContract;

  MainBloc(GlobalState<MainState> initialState, {required this.smartLoteryContract}) : super(initialState) {

    /*on<MainScreenDeposit1ETHEvent>((event, emit) async { // TODO Это с враппером
      await handleEventWrapper(() async {
        await _onDeposit1ETHEvent(event, emit);
      });
    });*/

    on<MainInitialEvent>((event, emit) async {
      await _onInit(event, emit);
    });

    on<MainScreenDeposit1ETHEvent>((event, emit) async {
      await _onDeposit1ETHEvent(event, emit);
    });

    on<MainRefreshEvent>((event, emit) async {
      await _onMainRefreshEvent(event, emit);
    });
  }

  _onMainRefreshEvent(MainRefreshEvent event, Emitter<GlobalState<MainState>> emit) async {
    final content = state.getContent()!;
    try {
      // Инициализация состояния
      final currentBalance = await smartLoteryContract.getCurrentUserBalance();
      final started = await smartLoteryContract.loteryStarted();
      final membersCount = await smartLoteryContract.getUsersCount();
      final loteryBalance = await smartLoteryContract.getLoteryBalance();
      emit(content.copyWith(
          ethBalance: currentBalance,
          started: started,
          usersCount: membersCount,
          loteryBalance: loteryBalance
      ).toContent());
    } catch(e) {
      handleHttpException(e, emit, content);
      emit(content.toContent());
    }
  }

  _onInit(MainInitialEvent event, Emitter<GlobalState<MainState>> emit) async {
    final content = state.getContent();
    try {
      // Инициализация контракта
      if (!smartLoteryContract.inited) {
        await smartLoteryContract.init();

        smartLoteryContract.subscribeToEvent(balanceChangedEventKeyConst, (p0) {
          print('Event received, value - $p0');
          add(MainRefreshEvent());
        });
      }

      // Инициализация состояния
      final currentBalance = await smartLoteryContract.getCurrentUserBalance();
      final started = await smartLoteryContract.loteryStarted();
      final membersCount = await smartLoteryContract.getUsersCount();
      final loteryBalance = await smartLoteryContract.getLoteryBalance();

      emit(content!.copyWith(
        ethBalance: currentBalance,
        started: started,
        usersCount: membersCount,
        loteryBalance: loteryBalance
      ).toContent());

      // Подписки на обновления от веб-сокета


    } catch(e) {
      if (content != null) {
        handleHttpException(e, emit, content);
        emit(content.toContent());
        return;
      }
      assert(false);
    }
  }

  _onDeposit1ETHEvent(MainScreenDeposit1ETHEvent event, Emitter<GlobalState<MainState>> emit) async {
    final content = state.getContent()!;
    try {
      emit(content.copyWith(depositButtonLoading: true).toContent());
      await smartLoteryContract.depositFunc(1); // TODO
      add(MainRefreshEvent());
    } catch(e) {
      handleHttpException(e, emit, content);
      emit(content.toContent());
      return;
    }
  }



}