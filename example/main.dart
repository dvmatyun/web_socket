import 'package:websocket_universal/websocket_universal.dart';

/// Example for custom Ping/Pong messages
/// IMessageProcessor that sends to and
/// receives simple [String] text from Server
class SocketCustomPingTextProcessor
    implements IMessageProcessor<String, String> {
  @override
  String? deserializeMessage(Object? data) {
    /// Here you can deserialize messages from server as you want it
    /// (so you can do something even with binary data)
    /// (see generic types and other examples for that)
    if (data is String) {
      return data;
    }
    return null;
  }

  /// !!! Here you define whether server response is Pong message
  /// (return true if [data] is PONG message from server)
  @override
  bool isPongMessageReceived(Object? data) {
    if (data is! String) {
      return false;
    }

    /// Echo server responds with same message, so here we consider both:
    /// '{"rpc":"custom_ping"}' and
    /// '{"rpc":"custom_pong"}' as PONG messages
    if (['{"rpc":"custom_pong"}', '{"rpc":"custom_ping"}'].contains(data)) {
      // Do not use 'print' in release version:
      // ignore: avoid_print
      print('> Message $data is PONG message received now!');
      return true;
    }
    return false;
  }

  /// !!! Here you define ping message (as object, can be even binary data)
  @override
  Object get pingServerMessage => '{"rpc":"custom_ping"}';

  /// Here you can serialize message as you wish
  /// For other type of message see generic type and other examples
  @override
  Object serializeMessage(String message) => message;
}

/// Example works with Postman Echo server
void main() async {
  /// Postman echo ws server (you can use your own server URI)
  /// 'wss://ws.postman-echo.com/raw'
  /// For local server it could look like 'ws://127.0.0.1:42627/websocket'
  const websocketConnectionUri = 'wss://ws.postman-echo.com/raw';
  const textMessageToServer = 'Hello server!';
  const connectionOptions = SocketConnectionOptions(
    pingIntervalMs: 1500, // send Ping message every 1500 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
    /// see ping/pong messages in [logEventStream] stream
    skipPingMessages: false,
  );

  /// Example with simple text messages exchanges with server
  /// (not recommended for applications)
  /// [<String, String>] generic types mean that we receive [String] messages
  /// after deserialization and send [String] messages to server.
  final IMessageProcessor<String, String> textSocketProcessor =
      SocketCustomPingTextProcessor();
  final textSocketHandler = IWebSocketHandler<String, String>.createClient(
    websocketConnectionUri, // Postman echo ws server
    textSocketProcessor,
    connectionOptions: connectionOptions,
  );

  // Listening to webSocket status changes
  textSocketHandler.socketHandlerStateStream.listen((stateEvent) {
    // ignore: avoid_print
    print('> status changed to ${stateEvent.status}');
  });

  // Listening to server responses: (here pong messages are NOT shown)
  textSocketHandler.incomingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket  got text message from server: "$inMsg" '
        '[ping: ${textSocketHandler.pingDelayMs}]');
  });

  // Listening to outgoing messages: (here ping messages are NOT shown)
  textSocketHandler.outgoingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket sent text message to   server: "$inMsg" '
        '[ping: ${textSocketHandler.pingDelayMs}]');
  });

  textSocketHandler.logEventStream
      .where(
    (e) => {
      SocketLogEventType.ping,
      SocketLogEventType.pong,
      SocketLogEventType.log,
    }.contains(e.socketLogEventType),
  )
      .listen((e) {
    // ignore: avoid_print
    print('> webSocket [type:${e.socketLogEventType.name}] '
        '[ping: ${textSocketHandler.pingDelayMs}] ${e.message} / ${e.data}');
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
