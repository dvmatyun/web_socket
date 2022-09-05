import 'dart:convert';

import '../interfaces/message_processor.dart';
import '../interfaces/message_to_server.dart';
import '../interfaces/socket_message.dart';
import '../models/socket_message_impl.dart';

/// [IMessageProcessor] for [ISocketMessage]-typed input messages from server
/// and [IMessageToServer]-typed outgoing messages to server
class SocketMessageProcessor
    implements IMessageProcessor<ISocketMessage<Object?>, IMessageToServer> {
  @override
  ISocketMessage? deserializeMessage(Object? data) {
    if (data is! String) {
      assert(false, 'Unsupported message type: ${data.runtimeType}');
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
