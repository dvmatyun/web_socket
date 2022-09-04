import 'dart:async';

import '../services/websocket_handler_io.dart'

// ignore: uri_does_not_exist
    if (dart.library.html) '../services/websocket_handler_html.dart';
import '../services/websocket_handler_mock.dart';
import 'message_processor.dart';
import 'socket_log_event.dart';
import 'socket_state.dart';

/// Basic websocket handler.
/// [T] is type of incoming deserialized messages
/// (that are received from server and deserialized)
/// [Y] is type of outgoing messages (that will be sent to server by you)
abstract class IWebSocketHandler<T, Y> {
  /// Last known ping-pong delay between server and client
  int get pingDelayMs;

  /// Stream of serialized messages to server
  Stream<Object> get outgoingMessagesStream;

  /// Stream of deserialized messages from server
  Stream<T> get incomingMessagesStream;

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
  void sendMessage(Y messageToServer);

  /// Dispose websocket handler (handler can not be used after calling [close])
  void close();

  /// Creates real websocket client depending on running platform (io / html). Requires server.
  /// [connectUrlBase] should look like [ws://127.0.0.1:42627/websocket]
  factory IWebSocketHandler.createClient(
    String connectUrlBase,
    IMessageProcessor<T, Y> messageProcessor, {
    int timeoutConnectionMs = 5000,
    int pingIntervalMs = 1000,
  }) =>
      createWebsocketClient(
        connectUrlBase,
        messageProcessor,
        timeoutConnectionMs: timeoutConnectionMs,
        pingIntervalMs: pingIntervalMs,
      );

  /// Created NOT REAL websocket client, that responses
  /// with same message as you send to it.
  /// Use only for debug purposes, no connection with server can be established
  factory IWebSocketHandler.createMockedWebsocketClient(
    String connectUrlBase,
    IMessageProcessor<T, Y> messageProcessor,
  ) =>
      createMockedWebsocketClient(
        connectUrlBase,
        messageProcessor,
      );
}
