import '../../../websocket_universal.dart';
import '../services/websocket_handler_impl.dart';

/// Basic websocket handler.
/// [Tin] is type of incoming deserialized messages
/// (that are received from server and deserialized)
/// [Yout] is type of outgoing messages (that will be sent to server by you)
abstract class IWebSocketHandler<Tin, Yout>
    implements IWebSocketBaseService<Tin, Yout> {
  /// Socket state changes that hides disconnected status between reconnecting
  /// attempts. Recommended to use this stream instead of [socketStateStream]
  Stream<ISocketState> get socketHandlerStateStream;

  /// Last socket state change that hides disconnected status between
  /// reconnecting attempts. Recommended to use this is you use
  /// [socketHandlerStateStream] stream.
  ISocketState get socketHandlerState;

  /// Creates real websocket client depending on running platform (io / html).
  /// Requires server.
  /// [socketUrl] should look like [ws://127.0.0.1:42627/websocket]
  /// [socketUrl] Postman echo service [wss://ws.postman-echo.com/raw]
  factory IWebSocketHandler.createClient(
    String socketUrl,
    IMessageProcessor<Tin, Yout> messageProcessor, {
    SocketConnectionOptions connectionOptions = const SocketConnectionOptions(),
  }) =>
      createWebsocketClient(
        socketUrl,
        messageProcessor,
        connectionOptions,
      );
}
