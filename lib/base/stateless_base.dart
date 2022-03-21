

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_base.dart';
import 'bloc_state_base.dart';

/// Статичный виждет с бизнес логикой.
/// Является обёрткой [StatelessWidget] с блоком [AdvancedBlocBase]
/// B - Конкретный компонент бизнес логики [AdvancedBlocBase]
/// E - Событие, связанное с бизнес логикой виджета
/// S - Конкретное состояние, связанное с виджетом
/// GlobalState<S> - Глобальное состояние виждета, связано с такими состояниями
/// как: загрузка виджета, ошибка, нормальное состояние, отсутсвие авторизации
///
/// Переопределите метод [onListen] для прослушки изменения состояния
/// Переопределите метод [onTokenExpired] для обработки случая протухания
/// токенов
/// Переопределите метод [onStateLoaded] для построения виждета
///
/// [addEvent] добавить событие в бизнес логику, не рекомендуется обращаться
/// к Bloc напрямую через поле
///
/// Особенность виджета в том, что компонент бизнес логики должен быть передан
/// в констуктор
abstract class StatelessWidgetWithBloc<
    B extends AdvancedBlocBase<E, GlobalState<S>, S>,
    E,
    S> extends StatelessWidget {
  final B bloc;

   const StatelessWidgetWithBloc({Key? key, required this.bloc})
      : super(key: key);

  /// Метод будет вызываться каждый раз, когда меняется состояние на [newState]
  void onListen(S newState, BuildContext context);

  /// Метод вызывается при протухании или некорректности токенов
  void onTokenExpired(BuildContext context);

  /// Основное тело виджета
  Widget onStateLoaded(S newState, BuildContext context);

  @mustCallSuper
  @protected
  void addEvent({required E event}) {
    bloc.add(event);
  }

  @protected
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, GlobalState<S>>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ResultStateBase) {
            return const SizedBox.shrink();
          }
          if (state is ErrorStateBase) {
            //return _onError();
          }
          if (state is LoadingStateBase) {
            return onLoading();
          }

          final content = state.getContent();
          if (content != null) {
            return onStateLoaded(content, context);
          }

          throw Exception();
        },
        listener: (context, state) {
          if (state is ResultStateBase) {
            onResult(context: context, result: state.getResult());
            return;
          }
          if (state is ErrorStateBase) {

            final snackBar = SnackBar(
              content: Text(state.getError() ?? 'Неизвестная ошибка'),
              /*action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),*/
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);

            return;
          }
          if (state is LoadingStateBase) {
            return;
          }
          if (state is UnauthorizedStateBase) {
            onTokenExpired(context);
          }
          final content = state.getContent();
          if (content != null) {
            onListen(content, context);
          }
        });
  }

  Widget onError();
  Widget onLoading();
  void onResult({required BuildContext context, required dynamic result});
}
