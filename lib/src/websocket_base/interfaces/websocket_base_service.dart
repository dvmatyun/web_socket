import 'dart:async';

import '../../../websocket_universal.dart';

/// Basic universal (multiplatform) websocket service.
/// [Tin] is type of incoming deserialized messages
/// (that are received from server and deserialized)
/// [Yout] is type of outgoing messages (that will be sent to server by you)
abstract class IWebSocketBaseService<Tin, Yout> {
  /// Last known ping-pong delay between server and client
  int get pingDelayMs;

  /// Stream of serialized messages to server
  /// It has [Object] type because ping message type can differ from
  /// [Yout] type.
  /// [WebSocketBaseService] does not add `Ping` messages to this stream
  Stream<Object> get outgoingMessagesStream;

  /// Stream of deserialized messages from server
  /// [WebSocketBaseService] does not add `Pong` messages to this stream
  Stream<Tin> get incomingMessagesStream;

  /// Socket state changes
  Stream<ISocketState> get socketStateStream;

  /// Current socket state
  ISocketState get socketState;

  /// Produces a lot of debug events:
  Stream<ISocketLogEvent> get logEventStream;

  /// Connect to server
  Future<bool> connect({
    SocketOptionalParams params = const SocketOptionalParams(),
  });

  /// Disconnect from server. [reason] may be any string
  Future<void> disconnect(String reason);

  /// Send generic message to server
  bool sendMessage(Yout messageToServer);

  /// Dispose websocket handler (handler can not be used after calling [close])
  /// You MUST create new WebSocket object in order to handle new events
  void close();

  /// Creates real websocket client depending on running platform (io / html). Requires server.
  /// [connectUrlBase] should look like [ws://127.0.0.1:42627/websocket]
  /// [timeoutConnectionMs] milliseconds timeout for establishing a connection
  /// Ping server with custom message every [pingIntervalMs] milliseconds
  /// Ping/pong messages are defined in [IMessageProcessor] class
  /// If [skipPingMessages] is FALSE then PING/PONG messages will be added to
  /// [outgoingMessagesStream] and [incomingMessagesStream] streams.
  factory IWebSocketBaseService.createClient(
    String connectUrlBase,
    IMessageProcessor<Tin, Yout> messageProcessor, {
    int timeoutConnectionMs = 5000,
    int pingIntervalMs = 2000,
    bool skipPingMessages = true,
    IPlatformWebsocket? platformWebsocket,
  }) =>
      createWebsocketBaseService(
        connectUrlBase,
        messageProcessor,
        timeoutConnectionMs: timeoutConnectionMs,
        pingIntervalMs: pingIntervalMs,
        skipPingMessages: skipPingMessages,
        platformWebsocket: platformWebsocket,
      );
}
