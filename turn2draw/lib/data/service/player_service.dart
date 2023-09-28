abstract class PlayerService {
  /// returns current player id (if any)
  Future<String?> getCurrentPlayerId();

  /// checks if player info is stored in local storage
  ///
  /// if no info is present, it will generate a random id & store the name with id
  Future<String> createPlayerIfNotExists(String playerName);

  /// returns currently stored player name, null if there is none
  Future<String?> getCurrentPlayerName();

  /// writes the current player name to local storage
  Future<String> setCurrentPlayerName(String playerName);
}
