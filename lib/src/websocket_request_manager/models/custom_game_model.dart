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

  /// Topic1 to get game model
  static const String topic1 = 'game';

  /// Topic1 to get game models list
  static const String topic1List = 'game-list';

  /// from json
  factory CustomGameModel.fromJson(Map<String, dynamic> json) =>
      _$CustomGameModelFromJson(json);

  /// to json
  Map<String, dynamic> toJson() => _$CustomGameModelToJson(this);

  @override
  String toString() => 'CustomGameModel : {$name, $playersAmount}';
}
