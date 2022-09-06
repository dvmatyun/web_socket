import 'dart:async';

import '../../../websocket_universal.dart';

class WebSocketRequestManager implements IWebSocketRequestManager {
  static const _stackTrace = '[AsyncSocketHandler] ';

  final IWebSocketHandler<ISocketMessage, ISocketMessage> _webSocketHandler;

  /// Streams:
  late final StreamSubscription _webSocketSub;
  final _decodedSc = StreamController<ITimedMessage>.broadcast();
  final _finishedRequestSc =
      StreamController<IFinishedSocketRequest>.broadcast();
  final _pingSc = StreamController<int>.broadcast();

  @override
  Stream<ITimedMessage> get decodedMessagesStream => _decodedSc.stream;

  @override
  Stream<IFinishedSocketRequest> get finishedRequestsStream =>
      _finishedRequestSc.stream;

  @override
  Stream<int> get pingMsStream => _pingSc.stream;

  /// Constructor
  WebSocketRequestManager({
    required IWebSocketHandler<ISocketMessage, ISocketMessage> webSocketHandler,
    required SendSocketMessageFunc sendSocketMessageFunc,
    required DecodeSocketMessageFunc decodeSocketMessageFunc,
  })  : _webSocketHandler = webSocketHandler,
        sendSocketMessageDelegate = sendSocketMessageFunc,
        decodeSocketMessageDelegate = decodeSocketMessageFunc {
    _webSocketSub =
        _webSocketHandler.incomingMessagesStream.listen(_socketListener);
  }

  final _notFinishedSocketRequests = <String, TimeoutSocketRequest>{};

  /// topic to list of not finished socket requests keys
  final _awaitedTopics = <String, List<String>>{};
  final _flaggedTopics = <String, DateTime>{};

  final _storedIncomingMessaged = <String, ITimedMessage>{};

  SendSocketMessageFunc? sendSocketMessageDelegate;
  DecodeSocketMessageFunc? decodeSocketMessageDelegate;

  @override
  void requestData(ISocketRequest socketRequest) {
    if (sendSocketMessageDelegate == null) {
      throw Exception('sendSocketMessageDelegate is not set!');
    }
    sendSocketMessageDelegate!(socketRequest.requestMessage, _webSocketHandler);
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
    if (decodeSocketMessageDelegate == null) {
      throw Exception('decodeSocketMessageDelegate is not set!');
    }
    final data = decodeSocketMessageDelegate!(socketMessage);
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
        final finishedRequest = FinishedSocketRequest(
          request: notFinishedRequest,
          dataDictionary: dataDictionary,
        );
        _pingSc.add(finishedRequest.msElapsed);
        //l.v('[decodeSocketMessageDelegate] _finishedRequestSc: ${finishedRequest.msElapsed}');
        _finishedRequestSc.add(finishedRequest);
      }
    }
  }

  @override
  ITimedMessage? getStoredDecodedMessage(String key) =>
      _storedIncomingMessaged[key];

  bool _allRequestedTopicsValid(
    TimeoutSocketRequest request,
    Map<String, DateTime> flaggedTopics,
  ) {
    for (final t in request.socketRequest.responseTopics) {
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
    Map<String, ITimedMessage> flaggedData,
  ) {
    final dataDictionary = <String, Object>{};
    final debugSb = StringBuffer();
    for (final t in request.socketRequest.responseTopics) {
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
    _decodedSc.close();
    _finishedRequestSc.close();
    _pingSc.close();
  }
}
