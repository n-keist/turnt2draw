import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/model/session_info.dart';

abstract class SessionService {
  SessionService();

  Future<SessionInfo?> findSession(String sessionId);

  Future<bool> joinSession(
    String sessionId,
    String playerId,
    String playerDisplayname,
    String? playerNotificationHandle,
  );

  Future<String?> startSession(CreateSessionConfig config);

  Future<String?> beginSession(String sessionId);
}
