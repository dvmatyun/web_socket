import 'package:json_annotation/json_annotation.dart';

import '../interfaces/message_to_server.dart';
import '../interfaces/socket_topic.dart';
import 'socket_topic_impl.dart';
part 'message_to_server_impl.g.dart';

@JsonSerializable(explicitToJson: true)
class MessageToServerImpl implements IMessageToServer {
  @override
  @JsonKey(fromJson: socketTopicFromJson, toJson: socketTopicToJson)
  final ISocketTopic topic;

  @override
  final String? data;

  @override
  final String? error;

  const MessageToServerImpl({required this.topic, this.data, this.error});

  MessageToServerImpl.duo({
    required String host,
    required String topic1,
    this.data,
  })  : error = null,
        topic = SocketTopicImpl.duo(host: host, topic1: topic1);

  MessageToServerImpl.trio({
    required String host,
    required String topic1,
    required String topic2,
    this.data,
  })  : error = null,
        topic =
            SocketTopicImpl.trio(host: host, topic1: topic1, topic2: topic2);

  factory MessageToServerImpl.fromJson(Map<String, dynamic> json) =>
      _$MessageToServerImplFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MessageToServerImplToJson(this);
}
