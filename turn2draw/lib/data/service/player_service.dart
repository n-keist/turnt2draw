abstract class PlayerService {
  Future<String?> getCurrentPlayerId();

  Future<String> createPlayerIfNotExists(String playerName);

  Future<String?> getCurrentPlayerName();

  Future<String> setCurrentPlayerName(String playerName);
}
