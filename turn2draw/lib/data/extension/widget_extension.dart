import 'package:flutter/material.dart';

extension ConditionalWidget on Widget {
  /// displays a [Widget] if the condition results in true
  /// otherwise returns null
  Widget? showWhen(bool Function() condition) {
    return condition.call() ? this : null;
  }
}
