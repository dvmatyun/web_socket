import 'package:test/test.dart';
import 'package:websocket_universal/websocket_universal.dart';

void main() {
  group('SocketMessageProcessor', () {
    test('constructor', () {
      expect(SocketMessageProcessor.new, returnsNormally);
      expect(SocketMessageProcessor(), isA<IMessageProcessor>());
    });

    test('serializeMessage', () {
      final processor = SocketMessageProcessor();
      final message = MessageToServerImpl(
        topic: SocketTopicImpl(orderedPathSegments: ['ping']),
        data: 'data',
        error: 'error',
      );
      expect(() => processor.serializeMessage(message), returnsNormally);
      expect(processor.serializeMessage(message), isA<String>());
      expect(
        processor.serializeMessage(message),
        equals('{"topic":"ping","data":"data","error":"error"}'),
      );
    });

    test('deserializeMessage', () {
      final processor = SocketMessageProcessor();
      const message = '{"topic":"pong","data":"data","error":"error"}';
      expect(() => processor.deserializeMessage(message), returnsNormally);
      expect(processor.deserializeMessage(message), isA<ISocketMessage>());
    });
  });
}
