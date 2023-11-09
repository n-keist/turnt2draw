import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ConditionalWidget on Widget {
  /// displays a [Widget] if the condition results in true
  /// otherwise returns null
  Widget? showWhen(bool Function() condition) {
    return condition.call() ? this : null;
  }
}

extension BlocListenerWidget on Widget {
  Widget addBlocListener<T extends StateStreamable<E>, E>(
    Function(BuildContext, E) fn, {
    bool Function(E, E)? listenWhen,
  }) {
    return BlocListener<T, E>(
      listenWhen: listenWhen,
      listener: fn,
      child: this,
    );
  }
}
