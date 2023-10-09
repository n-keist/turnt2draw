import 'dart:math';

extension ListExtension on List<String> {
  String randomElement() {
    return elementAt(Random().nextInt(length - 1));
  }
}
