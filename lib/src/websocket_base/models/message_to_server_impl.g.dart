// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_to_server_impl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageToServer _$MessageToServerFromJson(Map<String, dynamic> json) =>
    MessageToServer(
      topic: socketTopicFromJson(json['topic'] as String),
      data: json['data'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$MessageToServerToJson(MessageToServer instance) =>
    <String, dynamic>{
      'topic': socketTopicToJson(instance.topic),
      'data': instance.data,
      'error': instance.error,
    };
