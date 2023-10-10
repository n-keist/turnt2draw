import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/data/model/session_info.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn2draw/config/http.dart';
import 'package:turn2draw/config/logger.dart';
import 'package:turn2draw/config/preferences_keys.dart';

import 'package:http/http.dart' as http;
import 'package:turn2draw/data/unimplemented_preferences.dart';

part 'impl/remote_session_service.dart';

abstract class SessionService {
  SessionService();

  /// Looks up a session by a remote call
  ///
  /// If no session is found, it returns null
  Future<SessionInfo?> findSession(String sessionId);

  /// joins a session by id
  ///
  /// returns [true] if successful
  Future<bool> joinSession(Player player);

  /// creates a session by [config]
  ///
  /// returns the session id if everything went well,
  /// null if it failed
  Future<String?> startSession(CreateSessionConfig config);

  /// starts the session
  ///
  /// returns the current turn id if successful, null otherwise
  Future<String?> beginSession(String sessionId);

  /// joins a session which is selected by the server
  ///
  /// returns null if no session was found, otherwise the session id which was joined
  Future<String?> joinRandomSession(Player player);

  /// writes the last joined session to local storage
  Future<void> setLastSessionId(String sessionId);

  /// reads last joined session from local storage
  Future<String?> getLastSessionId();
}
