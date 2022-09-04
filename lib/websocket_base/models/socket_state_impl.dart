import '../enums/socket_status_type.dart';
import '../interfaces/socket_state.dart';

/// Websocket current state data implementation
class SocketStateImpl implements ISocketState {
  @override
  final SocketStatus status;
  @override
  final String message;

  @override
  final DateTime time;

  /// Constructor
  SocketStateImpl({required this.status, this.message = ''})
      : time = DateTime.now();
}
