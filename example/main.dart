import 'package:websocket_universal/websocket_universal.dart';

/// Example works with Postman Echo server
void main() async {
  /// Postman echo ws server (you can use your own server URI)
  /// For local server it could look like 'ws://127.0.0.1:42627/websocket'
  const websocketConnectionUri = 'wss://ws.postman-echo.com/raw';
  const textMessageToServer = 'Hello server!';

  /// Example with simple text messages exchanges with server
  /// (not recommended for applications)
  /// [<String, String>] generic types mean that we receive [String] messages
  /// after deserialization and send [String] messages to server.
  final IMessageProcessor<String, String> textSocketProcessor =
      SocketSimpleTextProcessor();
  final textSocketHandler = IWebSocketHandler<String, String>.createClient(
    websocketConnectionUri, // Postman echo ws server
    textSocketProcessor,
    pingIntervalMs: 3000, // send Ping message every 3000 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
    /// see ping/pong messages in
    /// [incomingMessagesStream] and [outgoingMessagesStream] streams
    skipPingMessages: false,
  );

  // Listening to server responses:
  textSocketHandler.incomingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket  got text message from server: "$inMsg"');
  });

  // Listening to outgoing messages:
  textSocketHandler.outgoingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket sent text message to   server: "$inMsg"');
  });

  // Connecting to server:
  final isTextSocketConnected = await textSocketHandler.connect();
  if (!isTextSocketConnected) {
    // ignore: avoid_print
    print('Connection to [$websocketConnectionUri] failed for some reason!');
    return;
  }

  textSocketHandler.sendMessage(textMessageToServer);

  await Future<void>.delayed(const Duration(seconds: 5));
  // Disconnecting from server:
  await textSocketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  textSocketHandler.close();
}
