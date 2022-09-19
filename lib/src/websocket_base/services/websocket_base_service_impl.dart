import 'dart:async';

import '../../../websocket_universal.dart';

/// Websocket base service factory
IWebSocketBaseService<T, Y> createWebsocketBaseService<T, Y>(
  String connectUrlBase,
  IMessageProcessor<T, Y> messageProcessor, {
  int timeoutConnectionMs = 5000,
  int pingIntervalMs = 2000,
  bool skipPingMessages = true,
}) =>
    WebSocketBaseService<T, Y>(
      connectUrlBase: connectUrlBase,
      messageProcessor: messageProcessor,
      timeoutConnectionMs: timeoutConnectionMs,
      pingIntervalMs: pingIntervalMs,
      skipPingMessages: skipPingMessages,
    );

/// Base implementation of [IWebSocketBaseService]
/// using [IPlatformWebsocket] abstraction
class WebSocketBaseService<T, Y> implements IWebSocketBaseService<T, Y> {
  final int _pingIntervalMs;
  final int _timeoutConnectionMs;
  final bool _skipPingMessages;

  /// consts:
  static const String _connectedPhrase = 'connected!';
  String _connectingPhrase(String url) => 'Connecting to [$url]...';

  final String _connectUrlBase;

  /// Ping measurement:
  final _pingStopwatch = Stopwatch();
  @override
  int get pingDelayMs => _pingDelayMs;
  int _pingDelayMs = 0;

  /// Serializer:
  final IMessageProcessor<T, Y> _messageProcessor;

  /// Messages TO server
  final _outgoingMessagesController = StreamController<Object>.broadcast();
  @override
  Stream<Object> get outgoingMessagesStream =>
      _outgoingMessagesController.stream;
  StreamSubscription? _toServerMessagesSub;

  /// Messages FROM server:
  final _incomingMessagesController = StreamController<T>.broadcast();
  @override
  Stream<T> get incomingMessagesStream => _incomingMessagesController.stream;
  StreamSubscription? _fromServerMessagesSub;

  /// Socket state notifications:
  final StreamController<ISocketState> _socketStateController =
      StreamController<ISocketState>.broadcast();
  @override
  Stream<ISocketState> get socketStateStream => _socketStateController.stream;

  ISocketState _socketState =
      SocketStateImpl(status: SocketStatus.disconnected, message: 'Created');
  @override
  ISocketState get socketState => _socketState;

  final _debugEventController = StreamController<ISocketLogEvent>.broadcast();
  @override
  Stream<ISocketLogEvent> get logEventStream => _debugEventController.stream;

  /// Internal state parameters:
  bool _disposed = false;

  /// Platform specific:
  final IPlatformWebsocket _platformWebSocket;

  /// [connectUrlBase] URL of websocket server. Example: 'ws://127.0.0.1:42627'
  /// [messageProcessor] how to process incoming and outgoing messages
  /// [timeoutConnectionMs] connection timeout in ms.
  /// Connection fails if not established during this timeout.
  /// [pingIntervalMs] how often send ping messages to server
  WebSocketBaseService({
    required String connectUrlBase,
    required IMessageProcessor<T, Y> messageProcessor,
    int timeoutConnectionMs = 5000,
    int pingIntervalMs = 1000,
    bool skipPingMessages = true,
  })  : _connectUrlBase = connectUrlBase,
        _messageProcessor = messageProcessor,
        _timeoutConnectionMs = timeoutConnectionMs,
        _pingIntervalMs = pingIntervalMs,
        _skipPingMessages = skipPingMessages,
        _platformWebSocket = IPlatformWebsocket.createPlatformWsClient();

  ///
  /// NOT CONNECTED
  /// Connecting:
  /// NOT CONNECTED
  ///
  @override
  Future<bool> connect() async {
    if (_disposed) {
      throw Exception('Socket is already disposed!');
    }
    try {
      if (socketState.status == SocketStatus.connected) {
        if (_checkPlatformIsConnected('connect method')) {
          return true;
        } else {
          await _internalDisconnect(
            'connection appears to be broken. Connecting again.',
          );
        }
      }
      _startPingMeasurement();
      final isConnected = await _connectionInitialize(_connectUrlBase);
      _setInitPing();
      if (isConnected) {
        await _connectionSuccessful();
        _isConnectionAlivePing();
        return true;
      }
      await _connectionUnsuccessful();

      return false;
    } on TimeoutException catch (_) {
      await _internalDisconnect(
        'Connection to [$_connectUrlBase] failed '
        'by timeout $_timeoutConnectionMs ms!',
      );
      return false;
    } on Object catch (e) {
      await _internalDisconnect('Internal error: $e');
      return false;
    }
  }

  Future<bool> _connectionInitialize(String baseUrl) async {
    if ([SocketStatus.connected, SocketStatus.connecting]
        .contains(socketState.status)) {
      return false;
    }
    _notifySocketStatusInternal(
      SocketStatus.connecting,
      _connectingPhrase(baseUrl),
    );
    final isConnected = await _platformWebSocket
        .connect(_connectUrlBase)
        .timeout(Duration(milliseconds: _timeoutConnectionMs));
    return isConnected;
  }

  Future<void> _connectionSuccessful() async {
    _notifySocketStatusInternal(SocketStatus.connected, _connectedPhrase);
    if (socketState.status != SocketStatus.connected) {
      return _internalDisconnect('Connection with server was not established!');
    }
    await _listenMessagerFromServer();
    await _listenMessagesToServer();
    // ignore: unawaited_futures
    _pingSocketState();
  }

  Future<void> _connectionUnsuccessful() async {
    await _internalDisconnect('Connection unsuccessful');
  }

  ///
  /// CONNECTED
  /// Listeners TO and FROM server:
  /// CONNECTED
  ///
  Future<void> _listenMessagerFromServer() async {
    _checkPlatformIsConnected('_listenMessagerFromServer');
    await _fromServerMessagesSub?.cancel();
    _fromServerMessagesSub = _platformWebSocket.incomingMessagesStream
        .listen(_fromServerMessageInternal);
  }

  Future<void> _listenMessagesToServer() async {
    _checkPlatformIsConnected('_listenMessagesToServer');
    await _toServerMessagesSub?.cancel();
    _toServerMessagesSub = outgoingMessagesStream
        .takeWhile((_) => socketState.status == SocketStatus.connected)
        .listen((e) => _addMessageToSocketOutgoingInternal(e, true));
  }

  ///
  /// CONNECTED
  /// Operating with connected socket:
  /// CONNECTED
  ///
  @override
  bool sendMessage(Y messageToServer) {
    if (!_checkPlatformIsConnected('sendMessage')) {
      return false;
    }
    _sendMessageInternal(messageToServer, false);
    return true;
  }

  void _sendMessageInternal(Object? data, bool isPing) {
    if (_disposed) {
      return;
    }
    if (socketState.status != SocketStatus.connected) {
      _debugEventNotificationInternal(
        SocketLogEventType.warning,
        'Trying to send message when not connected!',
      );
      return;
    }
    if (isPing) {
      _startPingRequest();
    }

    Object? dataToSend;
    if (data is Y) {
      dataToSend = _messageProcessor.serializeMessage(data);
    } else {
      dataToSend = data;
    }
    if (dataToSend == null) {
      _debugEventNotificationInternal(
        SocketLogEventType.warning,
        'Trying to send NULL data!',
      );
      return;
    }
    if (!isPing) {
      // This controller's stream is listened by [_listenMessagesToServer()]
      _outgoingMessagesController.add(dataToSend);
    } else {
      if (_skipPingMessages) {
        _addMessageToSocketOutgoingInternal(dataToSend, false);
      } else {
        _addMessageToSocketOutgoingInternal(dataToSend, true);
      }
    }
  }

  /// Sending to server platform implementation:
  void _addMessageToSocketOutgoingInternal(Object? input, bool notify) {
    try {
      if (input == null) {
        throw ArgumentError.notNull('[_addMessageToSocketOutgoingInternal] '
            'sent data must not be NULL!');
      }
      if (notify) {
        _debugEventNotificationInternal(
          SocketLogEventType.toServerMessage,
          'to server',
          data: input.toString(),
        );
      }

      _platformWebSocket.sendMessage(input);
    } on Object catch (e) {
      _debugEventNotificationInternal(
        SocketLogEventType.error,
        'Sending message to server failed! Error: $e',
        data: input.toString(),
      );
    }
  }

  /// Listening from server implementation:
  void _fromServerMessageInternal(dynamic input) {
    try {
      final data = input as Object?;
      final isPingMessage = _messageProcessor.isPongMessageReceived(data);
      if (isPingMessage) {
        _pongReceived();
      } else {
        final msgFromServer = _messageProcessor.deserializeMessage(data);
        if (msgFromServer == null) {
          _debugEventNotificationInternal(
            SocketLogEventType.warning,
            'Got NULL message from server!',
          );
          return;
        }
        _incomingMessagesController.add(msgFromServer);
      }

      if (!isPingMessage || !_skipPingMessages) {
        _debugEventNotificationInternal(
          SocketLogEventType.fromServerMessage,
          'from server',
          data: input.toString(),
        );
      }
    } on Object catch (e) {
      _debugEventNotificationInternal(
        SocketLogEventType.error,
        'Deserializing message from server failed! Error: $e',
        data: input.toString(),
      );
    }
  }

  ///
  ///
  /// Internal stuff:
  ///
  ///

  void _notifySocketStatusInternal(SocketStatus status, String message) {
    if (_socketStateController.isClosed) {
      return;
    }
    _socketState = SocketStateImpl(status: status, message: message);
    _socketStateController.add(_socketState);
    _debugEventNotificationInternal(
      SocketLogEventType.socketStateChanged,
      message,
    );
  }

  void _debugEventNotificationInternal(
    SocketLogEventType type,
    String message, {
    String? data,
  }) {
    if (_debugEventController.isClosed) {
      return;
    }
    final sb = StringBuffer(message);
    if ([SocketLogEventType.ping, SocketLogEventType.socketStateChanged]
        .contains(type)) {
      sb.write(_platformWebSocket.platformStatus);
    }

    _debugEventController.add(
      SocketLogEventImpl(
        socketLogEventType: type,
        status: _socketState.status,
        message: sb.toString(),
        pingMs: pingDelayMs,
        data: data,
      ),
    );
  }

  Future<void> _pingSocketState() async {
    while (socketState.status == SocketStatus.connected) {
      try {
        await Future<void>.delayed(Duration(milliseconds: _pingIntervalMs));
        // ignore: invariant_booleans
        if (socketState.status != SocketStatus.connected) {
          return;
        }
        _isConnectionAlivePing();
      } on Object catch (e) {
        _debugEventNotificationInternal(
          SocketLogEventType.ping,
          'Error occured while pinging: $e',
        );
      }
    }
  }

  bool _checkPlatformIsConnected(String whoChecks) {
    if (_pingStopwatch.elapsedMilliseconds > 2000) {
      _debugEventNotificationInternal(
        SocketLogEventType.ping,
        '$whoChecks : disconnected due to high ping',
      );
      return false;
    }
    if (_platformWebSocket.socketStatus != SocketStatus.connected) {
      _debugEventNotificationInternal(
        SocketLogEventType.ping,
        '$whoChecks ${_platformWebSocket.platformStatus}',
      );
      return false;
    }
    return true;
  }

  void _isConnectionAlivePing({String? message}) {
    if (_checkPlatformIsConnected('Ping socket.')) {
      _sendMessageInternal(_messageProcessor.pingServerMessage, true);

      final msg = 'Ping socket. Status: ${socketState.status.value}.';
      _debugEventNotificationInternal(
        SocketLogEventType.ping,
        message == null ? msg : '$msg ($message)',
      );
    } else {
      _internalDisconnect(
        'Connection appeared to be closed during pinging '
        'websocket platform status!',
      );
    }
  }

  ///
  /// Ping measurement:
  ///
  bool _isPongReceived = false;
  void _startPingRequest() {
    if (!_isPongReceived) {
      _recalculateCurrentPing(_pingStopwatch.elapsedMilliseconds);
    }
    _pingStopwatch.start();
    _isPongReceived = false;
  }

  void _pongReceived() {
    if (!_pingStopwatch.isRunning) {
      return;
    }
    _isPongReceived = true;
    _recalculateCurrentPing(_pingStopwatch.elapsedMilliseconds);
    _debugEventNotificationInternal(
      SocketLogEventType.pong,
      'pong from server (${_pingStopwatch.elapsedMilliseconds} ms.)',
    );
    _resetStopwatch();
  }

  void _resetStopwatch() {
    _pingStopwatch
      ..stop()
      ..reset();
  }

  void _recalculateCurrentPing(int newPingValue) {
    _pingDelayMs = (_pingDelayMs + newPingValue) ~/ 2;
  }

  void _startPingMeasurement() {
    _resetStopwatch();
    _pingStopwatch.start();
  }

  void _setInitPing() {
    if (!_pingStopwatch.isRunning) {
      return;
    }
    _recalculateCurrentPing(_pingStopwatch.elapsedMilliseconds);
    _resetStopwatch();
    _isPongReceived = true;
  }

  ///
  /// Closing & disconnecting
  ///
  @override
  Future<void> disconnect(String reason) async {
    await _internalDisconnect(reason);
  }

  /// Separate method is done in order to not to call super.disconnect()
  /// when [disconnect] is overriden as manual disconnect.
  Future<void> _internalDisconnect(String reason) async {
    _pingStopwatch.stop();
    if (socketState.status == SocketStatus.disconnected) {
      return;
    }
    await _fromServerMessagesSub?.cancel();
    await _platformWebSocket.close(3001, reason);
    _recalculateCurrentPing(9999);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _notifySocketStatusInternal(SocketStatus.disconnected, reason);
  }

  @override
  void close() {
    _pingStopwatch.stop();
    _fromServerMessagesSub?.cancel();
    _outgoingMessagesController.close();
    _incomingMessagesController.close();
    _socketStateController.close();
    _debugEventController.close();
    if (socketState.status != SocketStatus.disconnected) {
      _internalDisconnect('Close called (disposal)');
    }
    _disposed = true;
  }
}
