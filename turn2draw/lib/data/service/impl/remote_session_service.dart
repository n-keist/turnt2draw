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
        headers: {
          'x-draw-token': httpToken,
        },
      );
      return SessionInfo.parseJson(jsonDecode(response.body));
    } catch (e) {
      log('could not find session: $sessionId', error: e);
      return null;
    }
  }

  @override
  Future<SessionInfo?> findSessionByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/session',
          queryParameters: {
            'code': code,
          },
        ),
        headers: {
          'x-draw-token': httpToken,
        },
      );
      return SessionInfo.parseJson(jsonDecode(response.body));
    } catch (e) {
      log('could not find session by code: $code', error: e);
      return null;
    }
  }

  @override
  Future<bool> joinSession(Player player) async {
    try {
      final response = await http.put(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/session/${player.playerSession}/join',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-draw-token': httpToken,
        },
        body: jsonEncode(player.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      logger.e('could not join session ${player.playerSession}', error: e);
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
          'x-draw-token': httpToken,
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
        headers: {
          'x-draw-token': httpToken,
        },
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
  Future<String?> joinRandomSession(Player player) async {
    try {
      final response = await http.put(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/session/random/join',
        ),
        body: jsonEncode(player.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'x-draw-token': httpToken,
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
