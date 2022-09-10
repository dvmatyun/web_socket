import '../../../websocket_universal.dart';

/// WebSocket request to server that expects a collection of answers from
/// server in [timeoutMs] interval
abstract class ISocketRequest {
  /// Request to server
  IMessageToServer get requestMessage;

  /// Timeout time in milliseconds. If this time has passed and all required
  /// [responseTopics] are not received - request fails.
  int get timeoutMs;

  /// If [cacheTimeMs] hasn't passed since data was received then get stored
  /// value, otherwise - request and wait for new value. On null data is never
  /// obsolete.
  int? get cacheTimeMs;

  /// Multiple answers. When all answer topics are received,
  /// then the request is considered successful.
  Set<ISocketTopic> get responseTopics;

  /// Gets first topic from [responseTopics] or mirrors topic
  /// from [requestMessage]. Useful when request/response pair has same
  /// topics, e.g. we request from server 'game/get' and server responds with
  /// data using same 'game/get' topic
  ISocketTopic get firstTopicOrMirror;
}
