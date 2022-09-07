import '../../../websocket_universal.dart';

/// [ISocketMessage] with timestamp
abstract class ITimedMessage<T> implements ISocketMessage<T> {
  /// When message was received
  DateTime get timestamp;
}
