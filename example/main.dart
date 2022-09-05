import 'package:websocket_universal/websocket_universal.dart';

void main() async {
  // ignore: unused_local_variable
  const websocketLocalExample = 'ws://127.0.0.1:42627/websocket';
  const websocketConnectionUri = 'wss://ws.postman-echo.com/raw';

  /// Example using ISocketMessage and IMessageToServer:
  final IMessageProcessor<ISocketMessage<dynamic>, IMessageToServer>
      messageProcessor = SocketMessageProcessor();
  late final socketHandler = IWebSocketHandler.createClient(
    websocketConnectionUri, // Postman echo ws server
    messageProcessor,
    pingIntervalMs: 3000, // send Ping message every 3000 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
  );

  socketHandler.logEventStream.listen((debugEvent) {
    // ignore: avoid_print
    print('debugEvent: ${debugEvent.socketLogEventType}'
        ' ping=${debugEvent.pingMs}. Debug message=${debugEvent.message}');
  });
  socketHandler.socketStateStream.listen((stateEvent) {
    // ignore: avoid_print
    print('webSocket status changed to ${stateEvent.status}');
  });
  socketHandler.incomingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('webSocket got message: $inMsg');
  });

  // Connecting to server:
  final isConnected = await socketHandler.connect();

  if (!isConnected) {
    // ignore: avoid_print
    print('Connection to [$websocketConnectionUri] failed for some reason!');
    return;
  }

  final outMsg = MessageToServerImpl.onlyHost(host: 'test', data: 'mydata');
  socketHandler.sendMessage(outMsg);

  await Future<void>.delayed(const Duration(seconds: 8));
  // Disconnecting from server:
  await socketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  socketHandler.close();
}
