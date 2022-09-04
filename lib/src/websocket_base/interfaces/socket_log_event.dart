import '../enums/socket_log_event_type.dart';
import 'socket_state.dart';

/// Common log event interface for websocket
/// Listen to it in order to understand what is happening inside websocket
abstract class ISocketLogEvent implements ISocketState {
  /// Event type
  SocketLogEventType get socketLogEventType;

  /// Additional event data
  String? get data;

  /// Last known ping-pong delay between server and client
  int get pingMs;
}
