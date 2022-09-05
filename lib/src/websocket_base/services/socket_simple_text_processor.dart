import '../../../websocket_universal.dart';

/// IMessageProcessor that sends to and
/// receives simple [String] text from Server
class SocketSimpleTextProcessor implements IMessageProcessor<String, String> {
  @override
  String? deserializeMessage(Object? data) {
    if (data is String) {
      return data;
    }
    return null;
  }

  @override
  bool isPongMessageReceived(Object? data) {
    if (data is! String) {
      return false;
    }
    if (['ping', 'pong'].contains(data)) {
      return true;
    }
    return false;
  }

  @override
  Object get pingServerMessage => 'ping';

  @override
  Object serializeMessage(String message) => message;
}
