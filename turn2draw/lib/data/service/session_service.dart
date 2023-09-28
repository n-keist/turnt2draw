import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/model/session_info.dart';

abstract class SessionService {
  SessionService();

  /// Looks up a session by a remote call
  ///
  /// If no session is found, it returns null
  Future<SessionInfo?> findSession(String sessionId);

  /// joins a session by id
  ///
  /// returns [true] if successful
  Future<bool> joinSession(
    String sessionId,
    String playerId,
    String playerDisplayname,
    String? playerNotificationHandle,
  );

  /// creates a session by [config]
  ///
  /// returns the session id if everything went well,
  /// null if it failed
  Future<String?> startSession(CreateSessionConfig config);

  /// starts the session
  ///
  /// returns the current turn id if successful, null otherwise
  Future<String?> beginSession(String sessionId);
}
