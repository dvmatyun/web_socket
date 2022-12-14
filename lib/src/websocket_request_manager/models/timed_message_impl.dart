import '../../../websocket_universal.dart';

/// [ITimedSocketResponse] implementation with timestamp
class TimedMessage<T> implements ITimedSocketResponse<T>, ISocketMessage<T> {
  @override
  final DateTime timestamp;
  @override
  final T data;
  @override
  final String? error;

  @override
  final ISocketTopic topic;

  /// Default constructor
  TimedMessage({required this.data, required ISocketMessage socketMessage})
      : timestamp = DateTime.now(),
        error = socketMessage.error,
        topic = socketMessage.topic;

  /// Copy from another message
  TimedMessage.fromMessage({required ITimedSocketResponse msg})
      : timestamp = msg.timestamp,
        data = msg.data as T,
        error = msg.error,
        topic = msg.topic;
}
