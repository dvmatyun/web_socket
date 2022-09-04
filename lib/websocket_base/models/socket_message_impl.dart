import 'package:json_annotation/json_annotation.dart';

import '../interfaces/socket_message.dart';
import '../interfaces/socket_topic.dart';
import 'socket_topic_impl.dart';
part 'socket_message_impl.g.dart';

/// {@nodoc}
@JsonSerializable(explicitToJson: true)
class SocketMessageImpl implements ISocketMessage<dynamic> {
  @override
  @JsonKey(fromJson: socketTopicFromJson, toJson: socketTopicToJson)
  final ISocketTopic topic;

  @override
  final dynamic data;

  @override
  final String? error;

  const SocketMessageImpl({required this.topic, this.data, this.error});

  SocketMessageImpl.duo({
    required String host,
    required String topic1,
    this.data,
  })  : error = null,
        topic = SocketTopicImpl.duo(host: host, topic1: topic1);

  SocketMessageImpl.trio({
    required String host,
    required String topic1,
    required String topic2,
    this.data,
  })  : error = null,
        topic =
            SocketTopicImpl.trio(host: host, topic1: topic1, topic2: topic2);

  factory SocketMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$SocketMessageImplFromJson(json);

  Map<String, dynamic> toJson() => _$SocketMessageImplToJson(this);
}

class WebSocketTypedMessage<T> {
  late final ISocketTopic topic;
  final T? data;
  late final String? error;

  WebSocketTypedMessage(
      {required ISocketMessage webSocketMessage, required this.data,}) {
    topic = webSocketMessage.topic;
    error = webSocketMessage.error;
  }
}
