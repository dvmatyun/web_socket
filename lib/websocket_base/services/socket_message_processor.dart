import 'dart:convert';

import '../interfaces/message_processor.dart';
import '../interfaces/message_to_server.dart';
import '../interfaces/socket_message.dart';
import '../models/socket_message_impl.dart';

class SocketMessageProcessor
    implements IMessageProcessor<ISocketMessage<dynamic>, IMessageToServer> {
  @override
  ISocketMessage? deserializeMessage(Object? data) {
    if (data is! String) {
      return null;
    }
    final wsMessage =
        SocketMessageImpl.fromJson(jsonDecode(data) as Map<String, Object?>);
    return wsMessage;
  }

  @override
  Object serializeMessage(IMessageToServer message) =>
      jsonEncode(message.toJson());

  @override
  Object get pingServerMessage => 'ping';

  @override
  bool isPongMessageReceived(ISocketMessage? data) {
    if (data == null) {
      return false;
    }
    if (data.topic.host == 'pong') {
      return true;
    }
    return false;
  }
}
