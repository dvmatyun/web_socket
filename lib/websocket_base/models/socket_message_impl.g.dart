// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socket_message_impl.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketMessageImpl _$SocketMessageImplFromJson(Map<String, dynamic> json) =>
    SocketMessageImpl(
      topic: socketTopicFromJson(json['topic'] as String),
      data: json['data'],
      error: json['error'] as String?,
    );

Map<String, dynamic> _$SocketMessageImplToJson(SocketMessageImpl instance) =>
    <String, dynamic>{
      'topic': socketTopicToJson(instance.topic),
      'data': instance.data,
      'error': instance.error,
    };
