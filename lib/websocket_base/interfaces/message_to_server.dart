import 'socket_message.dart';

abstract class IMessageToServer implements ISocketMessage<String?> {
  /// Serialized as JSON string data
  @override
  String? get data;

  Map<String, dynamic> toJson();
}
