import '../enums/socket_status_type.dart';
import '../interfaces/socket_state.dart';

class SocketStateImpl implements ISocketState {
  @override
  final SocketStatus status;
  @override
  final String message;

  @override
  final DateTime time;

  SocketStateImpl({required this.status, this.message = ''})
      : time = DateTime.now();
}
