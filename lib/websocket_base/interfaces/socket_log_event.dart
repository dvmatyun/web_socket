import '../enums/socket_log_event_type.dart';
import 'socket_state.dart';

abstract class ISocketLogEvent implements ISocketState {
  SocketLogEventType get socketLogEventType;
  String? get data;
  int get pingMs;
}
