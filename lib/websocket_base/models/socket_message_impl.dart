import 'package:json_annotation/json_annotation.dart';

import '../interfaces/socket_message.dart';
import '../interfaces/socket_topic.dart';
import 'socket_topic_impl.dart';
part 'socket_message_impl.g.dart';

/// Convenient message model for websocket message
@JsonSerializable(explicitToJson: true)
class SocketMessageImpl implements ISocketMessage<dynamic> {
  @override
  @JsonKey(fromJson: socketTopicFromJson, toJson: socketTopicToJson)
  final ISocketTopic topic;

  @override
  final dynamic data;

  @override
  final String? error;

  /// Basic constructor
  const SocketMessageImpl({required this.topic, this.data, this.error});

  /// Constructor with 2 topic path segments - [host] and [topic1]
  SocketMessageImpl.duo({
    required String host,
    required String topic1,
    this.data,
    this.error,
  }) : topic = SocketTopicImpl.duo(host: host, topic1: topic1);

  /// Constructor with 2 topic path segments - [host], [topic1] and [topic2]
  SocketMessageImpl.trio({
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
  factory SocketMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$SocketMessageImplFromJson(json);

  /// Seralize object to JSON
  Map<String, dynamic> toJson() => _$SocketMessageImplToJson(this);
}
