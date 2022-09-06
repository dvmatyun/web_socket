import '../../../websocket_universal.dart';

class TimedMessage<T> implements ITimedMessage<T> {
  @override
  final ISocketMessage socketMessage;
  @override
  final DateTime timestamp;
  @override
  final T data;

  TimedMessage({required this.data, required this.socketMessage})
      : timestamp = DateTime.now();
  TimedMessage.fromMessage({required ITimedMessage msg})
      : socketMessage = msg.socketMessage,
        timestamp = msg.timestamp,
        data = msg.data as T;
}
