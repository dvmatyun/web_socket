import '../enums/socket_log_event_type.dart';
import '../interfaces/socket_log_event.dart';
import 'socket_state_impl.dart';

/// Common log event implementation for websocket
class SocketLogEventImpl extends SocketStateImpl implements ISocketLogEvent {
  @override
  final SocketLogEventType socketLogEventType;

  @override
  final String? data;

  @override
  final int pingMs;

  /// Constructor
  SocketLogEventImpl({
    required this.socketLogEventType,
    required super.status,
    required this.pingMs,
    super.message,
    this.data,
  });
}
