import 'package:flutter_test/flutter_test.dart';
import 'package:turn2draw/data/model/session_info.dart';

void main() {
  test('GameState is parsed correctly', () {
    expect(GameState.plain('drawing'), GameState.playing);
    expect(GameState.plain('done'), GameState.done);
  });
}
