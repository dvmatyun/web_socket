import '../../../websocket_universal.dart';

/// Request with time stored
class TimeoutSocketRequest extends SocketRequest implements ISocketRequest {
  /// When created
  final DateTime timeRequested;

  /// How much have passed since request was created
  int get msElapsed => DateTime.now().difference(timeRequested).inMilliseconds;

  /// Default constructor
  TimeoutSocketRequest({required ISocketRequest socketRequest})
      : timeRequested = DateTime.now(),
        super(
          requestMessage: socketRequest.requestMessage,
          timeoutMs: socketRequest.timeoutMs,
          responseTopics: socketRequest.responseTopics,
          cacheTimeMs: socketRequest.cacheTimeMs,
        );
}
