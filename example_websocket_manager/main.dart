import 'dart:convert';

import 'package:websocket_universal/websocket_universal.dart';

void main() async {
  /// Postman echo ws server (you can use your own server URI)
  /// For local server it could look like 'ws://127.0.0.1:42627/websocket'
  const websocketConnectionUri = 'wss://ws.postman-echo.com/raw';
  const connectionOptions = SocketConnectionOptions(
    pingIntervalMs: 3000, // send Ping message every 3000 ms
    timeoutConnectionMs: 4000, // connection fail timeout after 4000 ms
    /// see ping/pong messages in logEventStream stream
    skipPingMessages: false,

    /// Set this attribute to `true` if do not need any ping/pong
    /// messages and ping measurement. Default is `false`
    pingRestrictionForce: false,
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

  socketHandler.logEventStream.listen((logEvent) {
    // ignore: avoid_print
    print('> log ${logEvent.socketLogEventType} ${logEvent.pingMs} ms ping');
  });

  ///
  // Connecting to server:
  final isConnected = await socketHandler.connect();

  if (!isConnected) {
    // ignore: avoid_print
    print('Connection to [$websocketConnectionUri] failed for some reason!');
    return;
  }

  // Sending message with routing path 'test' and simple JSON payload:
  final requestGame = MessageToServer.duo(
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

  final outMsgList = MessageToServer.duo(
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
  // Emulating server 2nd response (real server should respond with 2
  // messages without 2nd request)
  dataBridge.requestData(socketRequestList);
  final compositeResp = await compositeTask;

  // In result we can get multiple results from composite response:
  final responseOne = compositeResp.getData<CustomGameModel>();
  final responseTwo = compositeResp.getData<List<CustomGameModel>>();

  // ignore: avoid_print
  print('Got composite result. Answers = ${compositeResp.dataCached.length}'
      '[$responseOne] and [$responseTwo]');

  // Listening to webSocket status changes
  socketHandler.socketHandlerStateStream.listen((stateEvent) {
    // ignore: avoid_print
    print('> status changed to ${stateEvent.status}');
  });
  await Future<void>.delayed(const Duration(seconds: 10));
  // Disconnecting from server:
  await socketHandler.disconnect('manual disconnect');
  // Disposing webSocket:
  requestManager.close();
  socketHandler.close();
}
