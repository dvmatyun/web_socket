import '../../../websocket_universal.dart';
import 'base_socket_decoder.dart';

/// Middleware implementation between socket handler and manager
class SocketManagerMiddleware implements ISocketManagerMiddleware {
  final _testDecoder = TestDecoder();

  @override
  Object? decodeSocketMessage(ISocketMessage socketMessage) {
    switch (socketMessage.topic.host) {
      case TestDecoder.host:
        return _testDecoder.decode(socketMessage, socketMessage.data as String);
    }
    return socketMessage.data;
  }

  @override
  ISocketMessage encodeSocketMessage(ISocketMessage socketMessage) =>
      socketMessage;
}

/// Test message decoder
class TestDecoder extends BaseDecode {
  /// Host for this decoder
  static const String host = 'test';
  static const String _stackTrace = 'TestDecoder';

  /// Decode socket message
  Object? decode(ISocketMessage socketMessage, String source) {
    switch (socketMessage.topic.topic1) {
      case CustomGameModel.topic1:
        final map = super.tryDecodeSingle(socketMessage, calledBy: _stackTrace);
        return CustomGameModel.fromJson(map);
      case CustomGameModel.topic1List:
        final list = super.tryDecodeList(socketMessage, calledBy: _stackTrace);
        final entities =
            list.map(CustomGameModel.fromJson).toList(growable: false);
        return entities;
    }

    return null;
  }
}
