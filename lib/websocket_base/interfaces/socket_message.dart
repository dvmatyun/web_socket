import 'socket_topic.dart';

/// Convenient interface for websocket messaging between server and client
abstract class ISocketMessage<T> {
  /// How server/client will understand how to route this message
  /// Same as URL path for common HTTP request
  ISocketTopic get topic;

  /// Generic data that message carries
  T get data;

  /// Property to report an error
  String? get error;
}
