import 'dart:async';

import '../../../websocket_universal.dart';

///
/// Handles websocket request on logic level using [ISocketMessage]
/// intraface. Times websocket requests.
///
class WebSocketRequestManager implements IWebSocketRequestManager {
  final IWebSocketHandler<ISocketMessage, ISocketMessage> _webSocketHandler;

  /// Streams:
  late final StreamSubscription _webSocketSub;
  late final StreamSubscription _webSocketPingSub;
  final _decodedSc = StreamController<ITimedSocketResponse>.broadcast();
  final _finishedRequestSc =
      StreamController<ICompositeSocketResponse>.broadcast();
  final _pingSc = StreamController<int>.broadcast();

  @override
  Stream<ITimedSocketResponse> get decodedMessagesStream => _decodedSc.stream;

  @override
  Stream<ICompositeSocketResponse> get finishedRequestsStream =>
      _finishedRequestSc.stream;

  @override
  Stream<int> get pingMsStream => _pingSc.stream;
  @override
  int get pingDelayMs => _lastPingMs;

  final ISocketManagerMiddleware _middleware;

  /// Constructor
  WebSocketRequestManager({
    required IWebSocketHandler<ISocketMessage, ISocketMessage> webSocketHandler,
    required ISocketManagerMiddleware middleware,
  })  : _webSocketHandler = webSocketHandler,
        _middleware = middleware,
        _lastPingMs = webSocketHandler.pingDelayMs {
    _webSocketSub =
        _webSocketHandler.incomingMessagesStream.listen(_socketListener);
    _webSocketPingSub = _webSocketHandler.logEventStream
        .where((e) => e.socketLogEventType == SocketLogEventType.pong)
        .listen((p) => _updatePing(p.pingMs));
  }

  final _notFinishedSocketRequests = <String, TimeoutSocketRequest>{};

  /// topic to list of not finished socket requests keys
  final _awaitedTopics = <String, List<String>>{};
  final _flaggedTopics = <String, DateTime>{};

  final _storedIncomingMessaged = <String, ITimedSocketResponse>{};

  @override
  void requestData(ISocketRequest socketRequest) {
    final outMessage =
        _middleware.encodeSocketMessage(socketRequest.requestMessage);
    _webSocketHandler.sendMessage(outMessage);
    if (socketRequest.responseTopics.isEmpty) {
      return;
    }

    _notFinishedSocketRequests[socketRequest.requestMessage.topic.path] =
        TimeoutSocketRequest(socketRequest: socketRequest);
    for (final t in socketRequest.responseTopics) {
      if (_awaitedTopics.containsKey(t.path)) {
        if (!(_awaitedTopics[t.path]
                ?.contains(socketRequest.requestMessage.topic.path) ??
            false)) {
          _awaitedTopics[t.path]?.add(socketRequest.requestMessage.topic.path);
        }
      } else {
        _awaitedTopics[t.path] = [socketRequest.requestMessage.topic.path];
      }
    }
  }

  void _socketListener(ISocketMessage socketMessage) {
    final data = _middleware.decodeSocketMessage(socketMessage);
    if (data == null) {
      return;
    }

    final timedMessage = TimedMessage(data: data, socketMessage: socketMessage);
    _storedIncomingMessaged[socketMessage.topic.path] = timedMessage;
    _flaggedTopics[socketMessage.topic.path] = DateTime.now();
    _decodedSc.add(timedMessage);

    final awaitedRequestsKeys = _awaitedTopics[socketMessage.topic.path];
    if (awaitedRequestsKeys == null) {
      return;
    }
    //awaitedRequestsKeys.remove(socketMessage.topic.path);
    for (final requestKey in awaitedRequestsKeys) {
      final notFinishedRequest = _notFinishedSocketRequests[requestKey];
      if (notFinishedRequest == null) {
        continue;
      }
      if (_allRequestedTopicsValid(notFinishedRequest, _flaggedTopics)) {
        _awaitedTopics.remove(socketMessage.topic.path);
        final dataDictionary = _assembleDataDictionary(
          notFinishedRequest,
          _storedIncomingMessaged,
        );
        final finishedRequest = CompositeSocketResponse(
          request: notFinishedRequest,
          dataCached: dataDictionary,
        );
        _updatePing(finishedRequest.msElapsed);
        _finishedRequestSc.add(finishedRequest);
      }
    }
  }

  int _lastPingMs = 0;
  void _updatePing(int newPingMs) {
    _lastPingMs = (newPingMs + _lastPingMs) ~/ 2;
    _pingSc.add(_lastPingMs);
  }

  @override
  ITimedSocketResponse? getStoredDecodedMessage(String key) =>
      _storedIncomingMessaged[key];

  bool _allRequestedTopicsValid(
    TimeoutSocketRequest request,
    Map<String, DateTime> flaggedTopics,
  ) {
    for (final t in request.responseTopics) {
      final flaggedTime = flaggedTopics[t.path];
      if (flaggedTime == null ||
          (flaggedTime.compareTo(request.timeRequested) < 0)) {
        return false;
      }
    }
    return true;
  }

  Map<String, Object> _assembleDataDictionary(
    TimeoutSocketRequest request,
    Map<String, ITimedSocketResponse> flaggedData,
  ) {
    final dataDictionary = <String, Object>{};
    final debugSb = StringBuffer();
    for (final t in request.responseTopics) {
      final timedMessage = flaggedData[t.path];
      if (timedMessage != null) {
        dataDictionary[t.path] = timedMessage.data as Object;
        debugSb.write('${t.path}:${timedMessage.timestamp};');
      }
    }
    return dataDictionary;
  }

  @override
  void close() {
    _webSocketSub.cancel();
    _webSocketPingSub.cancel();
    _decodedSc.close();
    _finishedRequestSc.close();
    _pingSc.close();
  }
}
