import '../../../websocket_universal.dart';

/// Middleware implementation between socket handler and manager
class SocketManagerMiddleware implements ISocketManagerMiddleware {
  @override
  Object? decodeSocketMessage(ISocketMessage socketMessage) {
    switch (socketMessage.topic.host) {
      case 'test':
        // Here you can call Test json deserializer
        return socketMessage.data;
    }
    return socketMessage.data;
  }

  @override
  ISocketMessage encodeSocketMessage(ISocketMessage socketMessage) =>
      socketMessage;
}
