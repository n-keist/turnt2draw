import 'package:flutter/foundation.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

part 'events/drawable_event.dart';
part 'events/socket_event.dart';
part 'events/local_event.dart';

abstract class SessionEvent {}
