import 'dart:async';

import '../services/websocket_handler.dart';
import '../services/websocket_handler_mock.dart';
import 'message_processor.dart';
import 'socket_log_event.dart';
import 'socket_state.dart';

/// Basic websocket handler.
/// [Tin] is type of incoming deserialized messages
/// (that are received from server and deserialized)
/// [Yout] is type of outgoing messages (that will be sent to server by you)
abstract class IWebSocketHandler<Tin, Yout> {
  /// Last known ping-pong delay between server and client
  int get pingDelayMs;

  /// Stream of serialized messages to server
  Stream<Object> get outgoingMessagesStream;

  /// Stream of deserialized messages from server
  Stream<Tin> get incomingMessagesStream;

  /// 0 - not connected
  /// 1 - connecting
  /// 2 - connected
  Stream<ISocketState> get socketStateStream;

  /// Current socket state
  ISocketState get socketState;

  /// Produces a lot of debug events:
  Stream<ISocketLogEvent> get logEventStream;

  /// Connect to server
  Future<bool> connect();

  /// Disconnect from server. [reason] may be any string
  Future<void> disconnect(String reason);

  /// Send generic message to server
  void sendMessage(Yout messageToServer);

  /// Dispose websocket handler (handler can not be used after calling [close])
  void close();

  /// Creates real websocket client depending on running platform (io / html). Requires server.
  /// [connectUrlBase] should look like [ws://127.0.0.1:42627/websocket]
  /// If [skipPingMessages] is FALSE then PING/PONG messages will be added to
  /// [outgoingMessagesStream] and [incomingMessagesStream] streams.
  factory IWebSocketHandler.createClient(
    String connectUrlBase,
    IMessageProcessor<Tin, Yout> messageProcessor, {
    int timeoutConnectionMs = 5000,
    int pingIntervalMs = 1000,
    bool skipPingMessages = true,
  }) =>
      createWebsocketClient(
        connectUrlBase,
        messageProcessor,
        timeoutConnectionMs: timeoutConnectionMs,
        pingIntervalMs: pingIntervalMs,
        skipPingMessages: skipPingMessages,
      );

  /// Created NOT REAL websocket client, that responses
  /// with same message as you send to it.
  /// Use only for debug purposes, no connection with server can be established
  factory IWebSocketHandler.createMockedWebsocketClient(
    String connectUrlBase,
    IMessageProcessor<Tin, Yout> messageProcessor,
  ) =>
      createMockedWebsocketClient(
        connectUrlBase,
        messageProcessor,
      );
}
