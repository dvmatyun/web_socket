import 'package:json_annotation/json_annotation.dart';

import '../interfaces/message_to_server.dart';
import '../interfaces/socket_topic.dart';
import 'socket_topic_impl.dart';

part 'message_to_server_impl.g.dart';

@JsonSerializable(explicitToJson: true)

/// Convenient message model to send message to server
class MessageToServer implements IMessageToServer {
  @override
  @JsonKey(fromJson: socketTopicFromJson, toJson: socketTopicToJson)
  final ISocketTopic topic;

  @override
  final String? data;

  @override
  final String? error;

  /// Basic constructor
  const MessageToServer({required this.topic, this.data, this.error});

  /// Constructor with single path segment - [host]
  MessageToServer.onlyHost({
    required String host,
    this.data,
    this.error,
  }) : topic = SocketTopicImpl.onlyHost(host: host);

  /// Constructor with 2 topic path segments - [host] and [topic1]
  MessageToServer.duo({
    required String host,
    required String topic1,
    this.data,
    this.error,
  }) : topic = SocketTopicImpl.duo(host: host, topic1: topic1);

  /// Constructor with 2 topic path segments - [host], [topic1] and [topic2]
  MessageToServer.trio({
    required String host,
    required String topic1,
    required String topic2,
    this.data,
    this.error,
  }) : topic = SocketTopicImpl.trio(
          host: host,
          topic1: topic1,
          topic2: topic2,
        );

  /// Deserialization from Json to object
  factory MessageToServer.fromJson(Map<String, dynamic> json) =>
      _$MessageToServerFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MessageToServerToJson(this);
}
