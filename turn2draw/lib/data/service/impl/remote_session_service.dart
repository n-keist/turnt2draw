import 'dart:convert';
import 'dart:developer';

import 'package:turn2draw/config/logger.dart';
import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/model/session_info.dart';
import 'package:turn2draw/data/service/session_service.dart';
import 'package:uno/uno.dart';

class RemoteSessionService extends SessionService {
  RemoteSessionService({Uno? uno}) : uno = uno ?? Uno();

  final Uno uno;

  @override
  Future<SessionInfo?> findSession(String sessionId) async {
    try {
      final response = await uno.get('/api/session/$sessionId');
      return SessionInfo.parseJson(response.data);
    } catch (e) {
      log('could not find session: $sessionId', error: e);
      return null;
    }
  }

  @override
  Future<bool> joinSession(
      String sessionId, String playerId, String playerDisplayname, String? playerNotificationHandle) async {
    try {
      final response = await uno.put(
        '/api/session/$sessionId/join',
        responseType: ResponseType.plain,
        headers: {
          'Content-Type': 'application/json',
        },
        data: {
          'playerId': playerId,
          'playerDisplayname': playerDisplayname,
          if (playerNotificationHandle != null) 'playerNotificationHandle': playerNotificationHandle,
        },
      );
      return response.status == 200;
    } catch (e) {
      log('could not join session: $sessionId', error: e);
      logger.e('could not join session $sessionId', error: e);
      return false;
    }
  }

  @override
  Future<String?> startSession(CreateSessionConfig config) async {
    try {
      final response = await uno.post('/api/session', data: config.toJson());
      if (response.status == 201) {
        return response.data['id'] as String;
      }
    } catch (e) {
      log('could not create session', error: e);
    }
    return null;
  }

  @override
  Future<String?> beginSession(String sessionId) async {
    try {
      final response = await uno.get(
        '/api/session/$sessionId/begin',
        validateStatus: (_) => true,
        responseType: ResponseType.plain,
      );
      if (response.status == 200) return null;
      final json = jsonDecode(response.data);
      return json['err_code'];
    } catch (e) {
      logger.e('could not begin session', error: e);
      return 'internal_error';
    }
  }
}
