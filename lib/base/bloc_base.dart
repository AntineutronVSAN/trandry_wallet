

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../datalayer/repositories/repository_base.dart';
import 'bloc_state_base.dart';

/// Кастомная обёртка на блоком Bloc
/// Применяется для пользовательской обработки событий,
/// а также для отлова ошибок при запросах на сервер
/// [E] - Событие, связанное с блоком
/// [S] - Глобальное состояние, связанное с блоком (подробнее описано в другом месте)
/// [LS] - Локальное состояние конкертного виждета
abstract class AdvancedBlocBase<E, S, LS> extends Bloc<E, S> {

  /// Если [eventsQueue] == false, то в таком случае пока блок обратывает
  /// событие, новые события не принимаются
  final bool eventsQueue;

  /// Если [eventsQueue] == false, может ли сейчас блок принять в обработку
  /// новое событие
  bool _canAcceptNewEvent = true;

  AdvancedBlocBase(S initialState, {
    this.eventsQueue = false,
  }) : super(initialState);

  /// Враппер позволяет перехватить новое событие и проверить, можно ли
  /// событие брать в обработку
  Future<void> handleEventWrapper(Function() func, {int? timeoutMls}) async {
    if (_canAcceptNewEvent) {
      _canAcceptNewEvent = false;
      await func();
      if (timeoutMls != null) {
        Future.delayed(Duration(milliseconds: timeoutMls)).then((value) {
        _canAcceptNewEvent = true;
        });
        return;
      }
      _canAcceptNewEvent = true;
    }
  }

  Future<bool> handleHttpException(Object e, Emitter<S> emit, LS state) async {

    if (e is RefreshTokenExpiredException) {
      emit(UnauthorizedStateBase<LS>(state) as S);
      print('НЕТ АВТОРИЗАЦИИ');
      return true;
    }

    if (e is UnknownServerException) {
      emit(ErrorStateBase<LS>(e.message, state) as S);
      return false;
    }

    emit(ErrorStateBase<LS>(e.toString(), state) as S);
    print('ERROR $e');
    return false;
  }

}