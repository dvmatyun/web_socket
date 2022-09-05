import 'dart:convert';

import '../../../websocket_universal.dart';

const String _deserializationErrorText =
    'SocketMessageProcessor error: could not deserialize SocketMessageImpl.';

/// [IMessageProcessor] for [ISocketMessage]-typed input messages from server
/// and [IMessageToServer]-typed outgoing messages to server
class SocketMessageProcessor
    implements IMessageProcessor<ISocketMessage<Object?>, IMessageToServer> {
  late final _pingMsg =
      serializeMessage(MessageToServerImpl.onlyHost(host: 'ping'));

  @override
  ISocketMessage? deserializeMessage(Object? data) {
    if (data is! String) {
      assert(false, 'Unsupported message type: ${data.runtimeType}');
      return null;
    }
    final map = jsonDecode(data) as Map<String, Object?>;
    try {
      final wsMessage = SocketMessageImpl.fromJson(map);
      return wsMessage;
    } on Object catch (_) {
      if (map.containsKey(topicJsonKey) && map[topicJsonKey] is String) {
        return SocketMessageImpl.onlyHost(
          host: (map[topicJsonKey] as String?) ?? 'empty',
          data: data,
          error: _deserializationErrorText,
        );
      }

      throw Exception('No $topicJsonKey JSON key found in received message!');
    }
  }

  @override
  Object serializeMessage(IMessageToServer message) =>
      jsonEncode(message.toJson());

  @override
  Object get pingServerMessage => _pingMsg;

  @override
  bool isPongMessageReceived(Object? data) {
    if (data == null) {
      return false;
    }
    if (data is! ISocketMessage) {
      return false;
    }
    if (data.topic.host == 'pong' || data.topic.host == 'ping') {
      return true;
    }
    return false;
  }
}
