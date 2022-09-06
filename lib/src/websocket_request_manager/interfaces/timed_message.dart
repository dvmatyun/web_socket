import '../../../websocket_universal.dart';

abstract class ITimedMessage<T> {
  ISocketMessage get socketMessage;
  DateTime get timestamp;
  T get data;
}
