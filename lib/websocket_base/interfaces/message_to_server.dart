import 'socket_message.dart';

/// Convenient interface to send message to server
abstract class IMessageToServer implements ISocketMessage<String?> {
  /// Seralize object to JSON
  Map<String, dynamic> toJson();
}
