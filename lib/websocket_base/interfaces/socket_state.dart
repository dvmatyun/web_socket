import '../enums/socket_status_type.dart';

abstract class ISocketState {
  SocketStatus get status;
  String get message;

  DateTime get time;
}
