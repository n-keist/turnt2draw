import 'package:emojis/emoji.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn2draw/config/preferences_keys.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/data/unimplemented_preferences.dart';

part 'impl/local_player_service.dart';

abstract class PlayerService {
  /// returns current player id (if any)
  Future<String?> getCurrentPlayerId();

  /// checks if player info is stored in local storage
  ///
  /// if no info is present, it will generate a random id & store the name with id
  Future<(String, String)> createPlayerIfNotExists(String playerName);

  /// returns currently stored player name, null if there is none
  Future<String?> getCurrentPlayerName();

  /// writes the current player name to local storage
  Future<String> setCurrentPlayerName(String playerName);

  /// stores the selected icon in local storage
  Future<void> setCurrentPlayerIcon(String icon);

  /// retrives stored icon
  Future<String?> getCurrentPlayerIcon();

  /// returns the whole player object with local stored properties
  Future<Player> getCurrentPlayer();
}
