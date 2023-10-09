part of '../player_service.dart';

class LocalPlayerService extends PlayerService {
  LocalPlayerService({SharedPreferences? preferences}) : preferences = preferences ?? UnimplementedPreferences();

  final SharedPreferences preferences;

  @override
  Future<(String, String)> createPlayerIfNotExists(String playerName) async {
    String? playerId = await getCurrentPlayerId();
    String? name = await getCurrentPlayerName();
    if (playerId != null && name != null) {
      return (playerId, playerName);
    }
    playerId = nanoid(length: 24);
    await preferences.setString(pGeneratedUserId, playerId);
    await preferences.setString(pGeneratedUsername, playerName);
    return (playerId, playerName);
  }

  @override
  Future<String?> getCurrentPlayerId() async {
    return preferences.getString(pGeneratedUserId);
  }

  @override
  Future<String?> getCurrentPlayerName() async {
    return preferences.getString(pGeneratedUsername);
  }

  @override
  Future<String> setCurrentPlayerName(String playerName) async {
    await preferences.setString(pGeneratedUsername, playerName);
    return playerName;
  }

  @override
  Future<String?> getCurrentPlayerIcon() async {
    final icon = preferences.getString(pGeneratedUserIcon);
    if (icon == null) return null;
    return Emoji.byShortName(icon)?.char;
  }

  @override
  Future<void> setCurrentPlayerIcon(String icon) async {
    await preferences.setString(pGeneratedUserIcon, icon);
  }

  @override
  Future<Player> getCurrentPlayer() async {
    return Player(
      playerId: await getCurrentPlayerId() ?? '',
      playerDisplayname: await getCurrentPlayerName() ?? '',
      playerIcon: await getCurrentPlayerIcon() ?? '',
    );
  }
}
