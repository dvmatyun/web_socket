import 'dart:async';

import '../../../websocket_universal.dart';

class WebSocketDataBridge {
  final IWebSocketRequestManager _requestManager;

  static const _stackTrace = '[RequestSocketDataHandler] ';

  WebSocketDataBridge({
    required IWebSocketRequestManager asyncSocketHandler,
  }) : _requestManager = asyncSocketHandler;

  void requestData(ISocketRequest request) {
    _requestManager.requestData(request);
  }

  /// Request entity that has request/response topic
  Future<T> singleRequest<T>(ISocketRequest request) async {
    final timedResult = await singleRequestFull<T>(request);
    return timedResult.data;
  }

  Future<ITimedMessage<T>> singleRequestFull<T>(ISocketRequest request) async {
    const method = 'singleRequestFull';
    if (request.responseTopics.isEmpty) {
      throw ArgumentError('$_stackTrace $method: response '
          'topics are empty!');
    }
    final responsePath = request.responseTopics.first.path;
    try {
      final task = _requestManager.decodedMessagesStream
          .firstWhere(
            (e) => e.socketMessage.topic.path == responsePath,
          )
          .timeout(Duration(milliseconds: request.timeoutMs));
      _requestManager.requestData(request);
      final result = await task;
      return TimedMessage.fromMessage(msg: result);
    } on TimeoutException {
      final errorMessage = '$_stackTrace $method ${request.timeoutMs} ms '
          'timeout passed awaiting for RESPONSE topic path: [$responsePath]';

      throw TimeoutException(errorMessage);
    } on Object {
      rethrow;
    }
  }

  Future<IFinishedSocketRequest> singleFinishedSocketRequest<T>(
    ISocketRequest request,
  ) async {
    const method = 'singleFinishedSocketRequest';
    if (request.responseTopics.isEmpty) {
      throw ArgumentError('$_stackTrace $method: response '
          'topics are empty!');
    }
    final requestPath = request.requestMessage.topic.path;
    try {
      final task = _requestManager.finishedRequestsStream
          .firstWhere(
            (e) => e.socketRequest.requestMessage.topic.path == requestPath,
          )
          .timeout(Duration(milliseconds: request.timeoutMs));
      _requestManager.requestData(request);
      final result = await task;
      return result;
    } on TimeoutException {
      final errorMessage = '$_stackTrace $method ${request.timeoutMs} ms '
          'timeout passed awaiting for REQUEST topic path: [$requestPath]';
      throw TimeoutException(errorMessage);
    } on Object {
      rethrow;
    }
  }

  final _storedStreams = <String, Stream>{};
  Stream<T> getStream<T>(ISocketTopic topic) {
    final responsePath = topic.path;

    if (_storedStreams.containsKey(responsePath)) {
      return _storedStreams[responsePath]! as Stream<T>;
    }
    _storedStreams[responsePath] = _requestManager.decodedMessagesStream
        .where(
          (e) => e.socketMessage.topic.path == responsePath,
        )
        .map<T>((event) => event.data as T);

    return _storedStreams[responsePath]! as Stream<T>;
  }

  T? getStored<T>(ISocketTopic topic) {
    final responsePath = topic.path;
    final msg = _requestManager.getStoredDecodedMessage(responsePath);
    if (msg == null) {
      return null;
    }
    return msg.data as T;
  }

  Future<T> tryGetStored<T>(ISocketRequest request) async {
    const method = 'tryGetStored';
    if (request.responseTopics.isEmpty) {
      throw ArgumentError('$_stackTrace $method: response '
          'topics are empty!');
    }
    final response = request.responseTopics.first.path;
    final msg = _requestManager.getStoredDecodedMessage(response);
    if (msg != null) {
      return msg.data as T;
    }
    return singleRequest<T>(request);
  }
}
