import '../../../websocket_universal.dart';

class TimeoutSocketRequest {
  final ISocketRequest socketRequest;
  final DateTime timeRequested;

  int get msElapsed => DateTime.now().difference(timeRequested).inMilliseconds;

  TimeoutSocketRequest({required this.socketRequest})
      : timeRequested = DateTime.now();
}
