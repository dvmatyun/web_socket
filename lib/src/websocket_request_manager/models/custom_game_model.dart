import 'package:json_annotation/json_annotation.dart';

part 'custom_game_model.g.dart';

/// Object for demonstration purposes
@JsonSerializable(explicitToJson: true)
class CustomGameModel {
  /// Game name
  final String name;

  /// Amount of players in game
  final int playersAmount;

  /// Constructor
  const CustomGameModel({
    required this.name,
    required this.playersAmount,
  });

  /// from json
  factory CustomGameModel.fromJson(Map<String, dynamic> json) =>
      _$CustomGameModelFromJson(json);

  /// to json
  Map<String, dynamic> toJson() => _$CustomGameModelToJson(this);
}
