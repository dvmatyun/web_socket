import '../enums/socket_status_type.dart';

/// Interface for websocket current state data
abstract class ISocketState {
  /// Websocket status
  SocketStatus get status;

  /// Additional status message
  String get message;

  /// When status was set
  DateTime get time;
}
