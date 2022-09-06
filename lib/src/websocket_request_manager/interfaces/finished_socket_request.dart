import '../../../websocket_universal.dart';

abstract class IFinishedSocketRequest {
  ISocketRequest get socketRequest;
  Map<String, ISocketMessage> get responses;
  DateTime get timeRequested;

  int get msElapsed;
  T getData<T>();
}
