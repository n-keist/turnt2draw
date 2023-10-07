part of '../session_service.dart';

class RemoteSessionService extends SessionService {
  RemoteSessionService({SharedPreferences? preferences}) : preferences = preferences ?? UnimplementedPreferences();

  final SharedPreferences preferences;

  @override
  Future<SessionInfo?> findSession(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/session/$sessionId',
        ),
      );
      return SessionInfo.parseJson(jsonDecode(response.body));
    } catch (e) {
      log('could not find session: $sessionId', error: e);
      return null;
    }
  }

  @override
  Future<bool> joinSession(
      String sessionId, String playerId, String playerDisplayname, String? playerNotificationHandle) async {
    try {
      final response = await http.put(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/session/$sessionId/join',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: {
          'playerId': playerId,
          'playerDisplayname': playerDisplayname,
          if (playerNotificationHandle != null) 'playerNotificationHandle': playerNotificationHandle,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      logger.e('could not join session $sessionId', error: e);
      return false;
    }
  }

  @override
  Future<String?> startSession(CreateSessionConfig config) async {
    try {
      final response = await http.post(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/session',
        ),
        body: jsonEncode(config.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 201) return null;
      final json = jsonDecode(response.body);
      return json['id'] as String;
    } catch (e) {
      logger.e('could not create session', error: e);
      return null;
    }
  }

  @override
  Future<String?> beginSession(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/session/$sessionId/begin',
        ),
      );
      if (response.statusCode == 200) return null;
      final json = jsonDecode(response.body);
      return json['err_code'];
    } catch (e) {
      logger.e('could not begin session', error: e);
      return 'internal_error';
    }
  }

  @override
  Future<String?> joinRandomSession(String playerId, String playerName) async {
    try {
      final response = await http.put(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/session/random/join',
        ),
        body: jsonEncode({
          'playerId': playerId,
          'playerDisplayname': playerName,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body);
      return json['sessionId'];
    } catch (e) {
      logger.e('COULD NOT JOIN RANDOM SESSION', error: e);
      return null;
    }
  }

  @override
  Future<String?> getLastSessionId() async {
    return preferences.getString(pLastSessionId);
  }

  @override
  Future<void> setLastSessionId(String sessionId) async {
    await preferences.setString(pLastSessionId, sessionId);
  }
}
