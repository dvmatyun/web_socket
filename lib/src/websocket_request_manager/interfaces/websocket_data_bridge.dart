import '../../../websocket_universal.dart';

/// Interface between ISocketRequest and getting actual data from server
abstract class IWebSocketDataBridge {
  /// Make request to server
  void requestData(ISocketRequest request);

  /// Request entity that has request/response topic
  Future<T> singleRequest<T>(ISocketRequest request);

  /// Request wrapped in [ITimedSocketResponse] entity that has request/response topic
  Future<ITimedSocketResponse<T>> singleRequestFull<T>(ISocketRequest request);

  /// Request that requires one or more (usually more) responses, that are
  /// defined in [ISocketRequest] `responseTopics` property
  Future<ICompositeSocketResponse> compositeRequest(ISocketRequest request);

  /// Get stream of data for specific topic
  Stream<T> getStream<T>(ISocketTopic topic);

  /// Get stream of response messages for specific topic
  Stream<ITimedSocketResponse<T>> getResponsesStream<T>(ISocketTopic topic);

  /// Get last received data value or null
  T? getStored<T>(ISocketTopic topic);

  /// Get last received data value or request it
  Future<T> tryGetStored<T>(ISocketRequest request);
}
