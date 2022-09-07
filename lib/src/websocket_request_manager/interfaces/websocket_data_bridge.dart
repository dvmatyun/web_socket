import '../../../websocket_universal.dart';

/// Interface between ISocketRequest and getting actual data from server
abstract class IWebSocketDataBridge {
  /// Request entity that has request/response topic
  Future<T> singleRequest<T>(ISocketRequest request);

  /// Request wrapped in [ITimedMessage] entity that has request/response topic
  Future<ITimedMessage<T>> singleRequestFull<T>(ISocketRequest request);

  /// Request that requires one or more (usually more) responses, that are
  /// defined in [ISocketRequest] `responseTopics` property
  Future<IFinishedSocketRequest> finishedRequest<T>(ISocketRequest request);
}
