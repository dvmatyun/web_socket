import 'dart:async';

import '../../../websocket_universal.dart';

/// Creates real websocket client depending on running platform (io / html).
/// Requires server.
/// [socketUrl] should look like [ws://127.0.0.1:42627/websocket]
/// [socketUrl] Postman echo service [wss://ws.postman-echo.com/raw]
/// [messageProcessor] handles in and out messages processing
/// [connectionOptions] socket handler connection options
/// you can pass your own implementation for [platformWebsocket] (optional)
IWebSocketHandler<T, Y> createWebsocketClient<T, Y>(
  String socketUrl,
  IMessageProcessor<T, Y> messageProcessor, {
  SocketConnectionOptions connectionOptions = const SocketConnectionOptions(),
  IPlatformWebsocket? platformWebsocket,
}) =>
    WebSocketHandler<T, Y>(
      socketUrl: socketUrl,
      messageProcessor: messageProcessor,
      connectionOptions: connectionOptions,
      platformWebsocket: platformWebsocket,
    );

/// Base implementation of [IWebSocketHandler]
/// using [WebSocketBaseService]
/// [Tin] is type of incoming deserialized messages
/// (that are received from server and deserialized)
/// [Yout] is type of outgoing messages (that will be sent to server by you)
/// Support automatic reconnection on socket disconnect.
/// Have all the same features as [IWebSocketBaseService]
class WebSocketHandler<Tin, Yout> extends WebSocketBaseService<Tin, Yout>
    implements IWebSocketHandler<Tin, Yout>, IWebSocketBaseService<Tin, Yout> {
  final SocketConnectionOptions _connectionOptions;

  /// [socketUrl] should look like [ws://127.0.0.1:42627/websocket]
  WebSocketHandler({
    required String socketUrl,
    required super.messageProcessor,
    required SocketConnectionOptions connectionOptions,
    super.platformWebsocket,
  })  : _connectionOptions = connectionOptions,
        super(
          connectUrlBase: socketUrl,
          pingIntervalMs: connectionOptions.pingIntervalMs,
          timeoutConnectionMs: connectionOptions.timeoutConnectionMs,
          skipPingMessages: connectionOptions.skipPingMessages,
          pingRestrictionForce: connectionOptions.pingRestrictionForce,
        );

  /// Short getters:
  int? get _failsLimit => _connectionOptions.failedReconnectionAttemptsLimit;
  int? get _failsPerMin => _connectionOptions.maxReconnectionAttemptsPerMinute;
  late final _periodicTimer = Timer.periodic(
    const Duration(seconds: 60),
    (_) => _onTimerTick(),
  );

  StreamSubscription? _socketStateSub;
  bool _disposed = false;
  bool _reconnectionEnabled = false;

  int _lastMinuteAttempts = 0;
  int _failedCombo = 0;

  /// Socket state notifications overriden:
  final StreamController<ISocketState> _socketReconnectStateController =
      StreamController<ISocketState>.broadcast();
  @override
  Stream<ISocketState> get socketHandlerStateStream =>
      _socketReconnectStateController.stream;

  ISocketState _socketReconnectingState =
      SocketStateImpl(status: SocketStatus.disconnected, message: 'Created');
  @override
  ISocketState get socketHandlerState => _socketReconnectingState;

  SocketOptionalParams _latestParams = const SocketOptionalParams();

  /// Connect to server
  @override
  Future<bool> connect({
    SocketOptionalParams params = const SocketOptionalParams(),
  }) async {
    if (_disposed) {
      return false;
    }
    _latestParams = params;
    await _initReconnectionCycle();
    final isConnected = await super.connect(params: params);
    return isConnected;
  }

  Future<void> _initReconnectionCycle() async {
    await _socketStateSub?.cancel();
    _reconnectionEnabled = true;
    _socketStateSub = super.socketStateStream.listen(_socketStateChanged);
  }

  Future<void> _socketStateChanged(ISocketState socketState) async {
    switch (socketState.status) {
      case SocketStatus.disconnected:
        final triedToReconnect = await _reconnectionAttempt();
        if (!triedToReconnect) {
          _notifyHandlerState(socketState);
        }
        return;
      case SocketStatus.connected:
        _notifyHandlerState(socketState);
        return _onConnection();
      case SocketStatus.connecting:
        return _notifyHandlerState(socketState);
    }
  }

  void _notifyHandlerState(ISocketState socketState) {
    _socketReconnectingState = socketState;
    _socketReconnectStateController.add(socketState);
  }

  void _onConnection() {
    _failedCombo = 0;
  }

  void _onTimerTick() {
    _lastMinuteAttempts = 0;
  }

  /// Return [bool] TRUE value means 'Reconnect attempt was done.'
  Future<bool> _reconnectionAttempt() async {
    if (!_reconnectionEnabled) {
      return false;
    }
    if (_failsLimit != null && _failedCombo > _failsLimit!) {
      return false;
    }
    if (_failsPerMin != null && _lastMinuteAttempts > _failsPerMin!) {
      return false;
    }
    await Future<void>.delayed(_connectionOptions.reconnectionDelay);
    final isConnected = await super.connect(params: _latestParams);
    if (isConnected) {
      return true;
    }
    _failedCombo++;
    _lastMinuteAttempts++;

    return true;
  }

  /// Disconnect from server. [reason] may be any string
  /// Stops any reconnection attempts until [connect] is called manually
  @override
  Future<void> disconnect(String reason) async {
    if (_disposed) {
      return;
    }
    _reconnectionEnabled = false;
    await super.disconnect(reason);
  }

  @override
  void close() {
    _disposed = true;
    _socketStateSub?.cancel();
    _periodicTimer.cancel();
    _socketReconnectStateController.close();
    super.close();
  }
}
