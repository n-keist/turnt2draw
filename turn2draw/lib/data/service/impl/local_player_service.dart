import 'package:nanoid2/nanoid2.dart';
import 'package:turn2draw/config/preferences_keys.dart';
import 'package:turn2draw/data/service/player_service.dart';
import 'package:turn2draw/storage/impl/in_memory_local_storage.dart';
import 'package:turn2draw/storage/local_storage.dart';

class LocalPlayerService extends PlayerService {
  LocalPlayerService({LocalStorage? localStorage}) : localStorage = localStorage ?? InMemoryLocalStorage();

  final LocalStorage localStorage;

  @override
  Future<String> createPlayerIfNotExists(String playerName) async {
    String? playerId = await getCurrentPlayerId();
    if (playerId != null) return playerId;
    playerId = nanoid(length: 24);
    await localStorage.write<String>(pGeneratedUserId, playerId);
    await localStorage.write<String>(pGeneratedUsername, playerName);
    return playerId;
  }

  @override
  Future<String?> getCurrentPlayerId() {
    return localStorage.read<String?>(pGeneratedUserId);
  }

  @override
  Future<String?> getCurrentPlayerName() {
    return localStorage.read<String?>(pGeneratedUsername);
  }

  @override
  Future<String> setCurrentPlayerName(String playerName) async {
    await localStorage.write<String>(pGeneratedUsername, playerName);
    return playerName;
  }
}
