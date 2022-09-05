// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_to_server_impl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageToServerImpl _$MessageToServerImplFromJson(Map<String, dynamic> json) =>
    MessageToServerImpl(
      topic: socketTopicFromJson(json['topic'] as String),
      data: json['data'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$MessageToServerImplToJson(
        MessageToServerImpl instance,) =>
    <String, dynamic>{
      'topic': socketTopicToJson(instance.topic),
      'data': instance.data,
      'error': instance.error,
    };
