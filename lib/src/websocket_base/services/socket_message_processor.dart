import 'dart:convert';

import '../../../websocket_universal.dart';

const String _deserializationErrorText =
    'SocketMessageProcessor error: could not deserialize SocketMessageImpl.';

/// [IMessageProcessor] for [ISocketMessage]-typed input messages from server
/// and [IMessageToServer]-typed outgoing messages to server
class SocketMessageProcessor
    implements IMessageProcessor<ISocketMessage<Object?>, IMessageToServer> {
  final Object _pingMsg;
  late final Set<Object> _pongMessages;

  /// Default constructor that sends ping message to server as 'ping' string
  /// and expects an answer from server as 'ping' or 'pong' string;
  SocketMessageProcessor()
      : _pingMsg = 'ping',
        _pongMessages = <Object>{'ping', 'pong'};

  /// Constructor with custom ping/pong messages
  /// Remember to implement Equality (==) operation
  SocketMessageProcessor.single(Object pingMessage, Object expectedPong)
      : _pingMsg = pingMessage,
        _pongMessages = <Object>{expectedPong};

  /// Constructor with custom ping/pong messages
  /// Remember to implement Equality (==) operation
  SocketMessageProcessor.custom(Object pingMessage, Set<Object> expectedPong)
      : _pingMsg = pingMessage,
        _pongMessages = expectedPong;

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
    if (_pongMessages.contains(data)) {
      return true;
    }
    return false;
  }
}
