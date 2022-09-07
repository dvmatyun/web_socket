// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomGameModel _$CustomGameModelFromJson(Map<String, dynamic> json) =>
    CustomGameModel(
      name: json['name'] as String,
      playersAmount: json['playersAmount'] as int,
    );

Map<String, dynamic> _$CustomGameModelToJson(CustomGameModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'playersAmount': instance.playersAmount,
    };
