import 'socket_topic.dart';

abstract class ISocketMessage<T> {
  ISocketTopic get topic;

  T get data;

  String? get error;
}
