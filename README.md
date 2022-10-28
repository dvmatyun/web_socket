# websocket_universal
[![CHECKOUT](https://github.com/dvmatyun/web_socket/actions/workflows/checkout.yml/badge.svg)](https://github.com/dvmatyun/web_socket/actions/workflows/checkout.yml)

## Easy-to-use interface:
1. Easy-to-use websocket methods and usage examples included!
2. Universal socket status changes stream.
3. Ping delay measurement and easy setup for ping/pong interaction with server!
4. Auto-reconnection feature for `IWebSocketHandler` ws handler.

## #1 Simple example with String messages (from and to server):
You don't need your own ws server to run this code.  
[Example postman echo server](https://blog.postman.com/introducing-postman-websocket-echo-service/) is used in this example.

1. Send message to server using `sendMessage(Y messageToServer)` and
listen messages coming from server using `incomingMessagesStream`
2. Listen to websocket states `socketStateStream` 
or all events that are happening `logEventStream`.
Define how you process your messages to and from server and ping/pong interaction
using `IMessageProcessor<Tin,Yout>` generic interface or use convinient
`SocketMessageProcessor` implementation (see example #2).

```dart
import 'package:websocket_universal/websocket_universal.dart';

/// Example works with Postman Echo server
void main() async {
  /// Postman echo ws server (you can use your own server URI)
  /// 'wss://ws.postman-echo.com/raw'
  /// For local server it could look like 'ws://127.0.0.1:42627/websocket'
  const websocketConnectionUri = 'wss://ws.postman-echo.com/raw';
  const textMessageToServer = 'Hello server!';
  const connectionOptions = SocketConnectionOptions(
    pingIntervalMs: 3000, // send Ping message every 3000 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
    /// see ping/pong messages in [logEventStream] stream
    skipPingMessages: false,

    /// Set this attribute to `true` if do not need any ping/pong
    /// messages and ping measurement. Default is `false`
    pingRestrictionForce: false,
  );

  /// Example with simple text messages exchanges with server
  /// (not recommended for applications)
  /// [<String, String>] generic types mean that we receive [String] messages
  /// after deserialization and send [String] messages to server.
  final IMessageProcessor<String, String> textSocketProcessor =
      SocketSimpleTextProcessor();
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

  // Listening to server responses:
  textSocketHandler.incomingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket  got text message from server: "$inMsg" '
        '[ping: ${textSocketHandler.pingDelayMs}]');
  });

  // Listening to debug events inside webSocket
  textSocketHandler.logEventStream.listen((debugEvent) {
    // ignore: avoid_print
    print('> debug event: ${debugEvent.socketLogEventType}'
        ' [ping=${debugEvent.pingMs} ms]. Debug message=${debugEvent.message}');
  });

  // Listening to outgoing messages:
  textSocketHandler.outgoingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket sent text message to   server: "$inMsg" '
        '[ping: ${textSocketHandler.pingDelayMs}]');
  });

  // Connecting to server:
  final isTextSocketConnected = await textSocketHandler.connect();
  if (!isTextSocketConnected) {
    // ignore: avoid_print
    print('Connection to [$websocketConnectionUri] failed for some reason!');
    return;
  }

  textSocketHandler.sendMessage(textMessageToServer);

  await Future<void>.delayed(const Duration(seconds: 30));
  // Disconnecting from server:
  await textSocketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  textSocketHandler.close();
}

```

## #2 Recommended way to exchange messages with server (typed Messages):
You don't need your own ws server to run this code.  
[Example postman echo server](https://blog.postman.com/introducing-postman-websocket-echo-service/) is used in this example.  

```dart
import 'package:websocket_universal/websocket_universal.dart';

void main() async {
  /// Postman echo ws server (you can use your own server URI)
  /// For local server it could look like 'ws://127.0.0.1:42627/websocket'
  const websocketConnectionUri = 'wss://ws.postman-echo.com/raw';
  const textMessageToServer = 'Hello server!';
  const connectionOptions = SocketConnectionOptions(
    pingIntervalMs: 3000, // send Ping message every 3000 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
    /// see ping/pong messages in [logEventStream] stream
    skipPingMessages: false,
  );

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
    connectionOptions: connectionOptions,
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
    data: '{"payload": "$textMessageToServer"}',
    error: null,
  );
  socketHandler.sendMessage(outMsg);

  await Future<void>.delayed(const Duration(seconds: 8));
  // Disconnecting from server:
  await socketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  socketHandler.close();
}
```

## #3 Handling byte messages (from and to server) on client side:

```dart
import 'dart:convert';

import 'package:websocket_universal/websocket_universal.dart';

/// Bytes array example:
void main() async {
  /// For getting/answering byte-array messages (`List<int> in dart`)
  /// you will need your own server and handle messages as byte-arrays
  /// on the backend side too. On client side it will look like this:
  const websocketLocalExample = 'ws://127.0.0.1:42627/websocket';
  const textMessageToServer = 'Hello server!';
  const connectionOptions = SocketConnectionOptions(
    pingIntervalMs: 3000, // send Ping message every 3000 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
    /// see ping/pong messages in [logEventStream] stream
    skipPingMessages: false,
  );

  final IMessageProcessor<List<int>, List<int>> bytesSocketProcessor =
      SocketSimpleBytesProcessor();
  final bytesSocketHandler =
      IWebSocketHandler<List<int>, List<int>>.createClient(
    websocketLocalExample, // Local ws server
    bytesSocketProcessor,
    connectionOptions: connectionOptions,
  );

  // Listening to debug events inside webSocket
  bytesSocketHandler.logEventStream.listen((debugEvent) {
    // ignore: avoid_print
    print('> debug event: ${debugEvent.socketLogEventType}'
        ' ping=${debugEvent.pingMs} ms. Debug message=${debugEvent.message}');
  });

  // Listening to server responses:
  bytesSocketHandler.incomingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket  got bytes message from server: "$inMsg"');
  });

  // Listening to outgoing messages:
  bytesSocketHandler.outgoingMessagesStream.listen((inMsg) {
    // ignore: avoid_print
    print('> webSocket sent bytes message to   server: "$inMsg"');
  });

  // Connecting to server:
  final isBytesSocketConnected = await bytesSocketHandler.connect();
  if (!isBytesSocketConnected) {
    // ignore: avoid_print
    print('Connection to [$websocketLocalExample] for bytesSocketHandler '
        'failed for some reason!');
    return;
  }
  final bytesMessage = utf8.encode(textMessageToServer);
  //textMessageToServer
  bytesSocketHandler.sendMessage(bytesMessage);

  await Future<void>.delayed(const Duration(seconds: 7));
  // Disconnecting from server:
  await bytesSocketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  bytesSocketHandler.close();
}

```

## #4 Advanced ISocketMessage handling. Composite server response example:

```dart
import 'dart:convert';

import 'package:websocket_universal/websocket_universal.dart';

void main() async {
  /// Postman echo ws server (you can use your own server URI)
  /// For local server it could look like 'ws://127.0.0.1:42627/websocket'
  const websocketConnectionUri = 'wss://ws.postman-echo.com/raw';
  const connectionOptions = SocketConnectionOptions(
    pingIntervalMs: 3000, // send Ping message every 3000 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
    /// see ping/pong messages in [logEventStream] stream
    skipPingMessages: false,
  );

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
    connectionOptions: connectionOptions,
  );

  /// Creating websocket_manager:
  /// `ISocketManagerMiddleware` processes requests before sending and
  /// after receiving ISocketMessage. See test implementation for details.
  final ISocketManagerMiddleware middleware = SocketManagerMiddleware();
  final IWebSocketRequestManager requestManager = WebSocketRequestManager(
    middleware: middleware,
    webSocketHandler: socketHandler,
  );
  final IWebSocketDataBridge dataBridge = WebSocketDataBridge(requestManager);

  ///
  // Connecting to server:
  final isConnected = await socketHandler.connect();

  if (!isConnected) {
    // ignore: avoid_print
    print('Connection to [$websocketConnectionUri] failed for some reason!');
    return;
  }

  // Sending message with routing path 'test' and simple JSON payload:
  final requestGame = MessageToServerImpl.duo(
    host: TestDecoder.host,
    topic1: CustomGameModel.topic1,
    data: jsonEncode(
      const CustomGameModel(
        name: 'MakeWorld strategy',
        playersAmount: 8,
      ),
    ),
    error: null,
  );
  final socketRequest = SocketRequest(requestMessage: requestGame);

  final result =
      await dataBridge.singleRequestFull<CustomGameModel>(socketRequest);
  // ignore: avoid_print
  print('Got result: ${result.data}');

  final outMsgList = MessageToServerImpl.duo(
    host: TestDecoder.host,
    topic1: CustomGameModel.topic1List,
    data: jsonEncode([
      const CustomGameModel(
        name: 'MakeWorld strategy',
        playersAmount: 8,
      ),
      const CustomGameModel(
        name: 'New patch',
        playersAmount: 4,
      ),
    ]),
    error: null,
  );
  final socketRequestList = SocketRequest(requestMessage: outMsgList);

  final listResult = await dataBridge
      .singleRequestFull<List<CustomGameModel>>(socketRequestList);
  // ignore: avoid_print
  print('Got list result: ${listResult.data}');

  // Creating composite request with 2 response topics required
  final topicSingle = SocketTopicImpl.duo(
    host: TestDecoder.host,
    topic1: CustomGameModel.topic1,
  );
  final topicList = SocketTopicImpl.duo(
    host: TestDecoder.host,
    topic1: CustomGameModel.topic1List,
  );
  // Assemple composite request, that, in fact, requests CustomGameModel
  // using [requestGame] to request single game and awaits to receive 2 topics
  // from server: [topicSingle] and [topicList]
  final compositeRequest = SocketRequest(
    requestMessage: requestGame,
    responseTopics: {topicSingle, topicList},
  );
  // Running task:
  final compositeTask = dataBridge.compositeRequest(compositeRequest);
  // Emulating server 2nd response (real server should response with 2
  // messages without 2nd request)
  dataBridge.requestData(socketRequestList);
  final compositeResp = await compositeTask;

  // In result we can get multiple results from composite response:
  final responseOne = compositeResp.getData<CustomGameModel>();
  final responseTwo = compositeResp.getData<List<CustomGameModel>>();

  // ignore: avoid_print
  print('Got composite result. Answers = ${compositeResp.dataCached.length}'
      '[$responseOne] and [$responseTwo]');

  // Disconnecting from server:
  await socketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  requestManager.close();
  socketHandler.close();
}

```

[Source repository](https://github.com/dvmatyun/web_socket)