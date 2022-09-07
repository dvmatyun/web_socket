import '../../../websocket_universal.dart';

/// WebSocket request to server
class SocketRequest implements ISocketRequest {
  @override
  final ISocketMessage requestMessage;
  @override
  final int timeoutMs;
  @override
  final Set<ISocketTopic> responseTopics;

  /// Default constructor
  const SocketRequest({
    required this.requestMessage,
    this.timeoutMs = 2000,
    this.responseTopics = const {},
  });

  @override
  ISocketTopic get firstTopicOrMirror =>
      responseTopics.firstOrNull() ?? requestMessage.topic;
}

/// Inner extension
extension IEnumerableExtension<T> on Iterable<T> {
  /// Gets first element if exists, or null otherwise
  T? firstOrNull() => isEmpty ? null : first;
}
