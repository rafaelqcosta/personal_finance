import 'package:flutter/widgets.dart';
import 'package:personal_finance/app/core/failures/failure.dart';

enum BaseState { loading, error, success }

class BaseController<T> {
  ValueNotifier<T> success;
  ValueNotifier<BaseState> state;
  ValueNotifier<Failure?> failure;

  BaseController(T initialState)
    : success = ValueNotifier<T>(initialState),
      state = ValueNotifier<BaseState>(BaseState.success),
      failure = ValueNotifier<Failure?>(null);

  void setLoading() {
    state.value = BaseState.loading;
    failure.value = null;
  }

  void update(T newData) {
    success.value = newData;
    state.value = BaseState.success;
    failure.value = null;
  }

  void setError(Failure error) {
    failure.value = error;
    state.value = BaseState.error;
  }
}
