import '../../../websocket_universal.dart';

/// WebSocket request to server that expects a collection of answers from
/// server in [timeoutMs] interval
abstract class ISocketRequest {
  /// Request to server
  ISocketMessage get requestMessage;

  /// Timeout time in milliseconds. If this time has passed and all required
  ///
  int get timeoutMs;

  /// Multiple answers. When all answer topics are received,
  /// then the request is considered successful.
  Set<ISocketTopic> get responseTopics;
}
