import 'package:websocket_universal/websocket_universal.dart';

void main() async {
  // ignore: unused_local_variable
  const websocketLocalExample = 'ws://127.0.0.1:42627/websocket';

  /// Postman echo ws server (you can use your own server URI)
  const websocketConnectionUri = 'wss://ws.postman-echo.com/raw';

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

  const textMessageToServer = 'Hello server!';
  textSocketHandler.sendMessage(textMessageToServer);

  await Future<void>.delayed(const Duration(seconds: 5));
  // Disconnecting from server:
  await textSocketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  textSocketHandler.close();

  /// Complex example:
  /// Example using [ISocketMessage] and [IMessageToServer]
  /// (recommended for applications, server must deserialize
  /// [ISocketMessage] serialized string to [ISocketMessage] object)
  final IMessageProcessor<ISocketMessage<Object?>, IMessageToServer>
      messageProcessor = SocketMessageProcessor();
  final socketHandler =
      IWebSocketHandler<ISocketMessage<Object?>, IMessageToServer>.createClient(
    websocketConnectionUri,
    messageProcessor,
    pingIntervalMs: 3000, // send Ping message every 3000 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
  );

  // Listening to debug events inside webSocket
  socketHandler.logEventStream.listen((debugEvent) {
    // ignore: avoid_print
    print('> debug event: ${debugEvent.socketLogEventType}'
        ' ping=${debugEvent.pingMs} ms. Debug message=${debugEvent.message}');
  });

  // Listening to webSocket status changes
  socketHandler.socketStateStream.listen((stateEvent) {
    // ignore: avoid_print
    print('> status changed to ${stateEvent.status}');
  });

  // [IMessageToServer] also implements [ISocketMessage] interface.
  // So basically we are sending and receiving equally-typed messages.
  const messageTypeStr = '[ISocketMessage]';
  // Listening to server responses:
  socketHandler.incomingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket  got $messageTypeStr: $inMsg');
  });

  // Listening to outgoing messages:
  socketHandler.outgoingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket sent $messageTypeStr: $inMsg');
  });

  // Connecting to server:
  final isConnected = await socketHandler.connect();

  if (!isConnected) {
    // ignore: avoid_print
    print('Connection to [$websocketConnectionUri] failed for some reason!');
    return;
  }

  // Sending message with routing path 'test' and simple JSON payload:
  final outMsg = MessageToServerImpl.onlyHost(
    host: 'test',
    data: '{"payload": "mydata"}',
    error: null,
  );
  socketHandler.sendMessage(outMsg);

  await Future<void>.delayed(const Duration(seconds: 8));
  // Disconnecting from server:
  await socketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  socketHandler.close();
}
