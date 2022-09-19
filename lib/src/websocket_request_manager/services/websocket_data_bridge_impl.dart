import 'dart:async';

import '../../../websocket_universal.dart';

/// Data bridge between sending [ISocketRequest] and getting useful data from
/// websocket
class WebSocketDataBridge implements IWebSocketDataBridge {
  final IWebSocketRequestManager _requestManager;

  static const _stackTrace = '[RequestSocketDataHandler] ';

  /// Default constructor
  WebSocketDataBridge(
    IWebSocketRequestManager requestManager,
  ) : _requestManager = requestManager;

  @override
  void requestData(ISocketRequest request) =>
      _requestManager.requestData(request);

  @override
  Future<T> singleRequest<T>(ISocketRequest request) async {
    final timedResult = await singleRequestFull<T>(request);
    return timedResult.data;
  }

  @override
  Future<ITimedSocketResponse<T>> singleRequestFull<T>(
    ISocketRequest request,
  ) async {
    const method = 'singleRequestFull';
    final responsePath = request.firstTopicOrMirror.path;
    try {
      final task = _requestManager.decodedMessagesStream.firstWhere(
        (e) => e.topic.path == responsePath,
      );

      _requestManager.requestData(request);
      ITimedSocketResponse<dynamic> result;
      if (request.timeoutMs != null) {
        result = await task.timeout(Duration(milliseconds: request.timeoutMs!));
      } else {
        result = await task;
      }

      if (result.data is T) {
        return TimedMessage.fromMessage(msg: result);
      }
      throw Exception(
        '$_stackTrace $method : received data is wrongly typed! '
        '(topic path: $responsePath)',
      );
    } on TimeoutException {
      final errorMessage = '$_stackTrace $method ${request.timeoutMs} ms '
          'timeout passed awaiting for RESPONSE topic path: [$responsePath]';

      throw TimeoutException(errorMessage);
    } on Object {
      rethrow;
    }
  }

  @override
  Future<ICompositeSocketResponse> compositeRequest(
    ISocketRequest request,
  ) async {
    const method = 'finishedRequest';
    if (request.responseTopics.isEmpty) {
      throw ArgumentError('$_stackTrace $method: response '
          'topics are empty!');
    }
    final requestPath = request.requestMessage.topic.path;
    try {
      final task = _requestManager.finishedRequestsStream.firstWhere(
        (e) => e.socketRequest.requestMessage.topic.path == requestPath,
      );
      _requestManager.requestData(request);

      ICompositeSocketResponse result;
      if (request.timeoutMs != null) {
        result = await task.timeout(Duration(milliseconds: request.timeoutMs!));
      } else {
        result = await task;
      }
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

  @override
  T? getStored<T>(ISocketTopic topic) {
    final responsePath = topic.path;
    final msg = _requestManager.getStoredDecodedMessage(responsePath);
    if (msg == null) {
      return null;
    }
    return msg.data as T;
  }

  @override
  Future<T> tryGetStored<T>(ISocketRequest request) async {
    final response = request.firstTopicOrMirror.path;
    final msg = _requestManager.getStoredDecodedMessage(response);
    if (msg != null &&
        (request.cacheTimeMs == null ||
            DateTime.now().difference(msg.timestamp).inMilliseconds <
                (request.cacheTimeMs ?? 0))) {
      return msg.data as T;
    }
    return singleRequest<T>(request);
  }

  @override
  Stream<T> getStream<T>(ISocketTopic topic) {
    final responsePath = topic.path;

    if (_storedStreams.containsKey(responsePath)) {
      return _storedStreams[responsePath]! as Stream<T>;
    }
    _storedStreams[responsePath] = _requestManager.decodedMessagesStream
        .where(
          (e) => e.topic.path == responsePath,
        )
        .map<T>((event) => event.data as T);

    return _storedStreams[responsePath]! as Stream<T>;
  }

  @override
  Stream<ITimedSocketResponse<T>> getResponsesStream<T>(ISocketTopic topic) {
    final responsePath = topic.path;
    final streamKey = 't.${topic.path}';

    if (_storedStreams.containsKey(streamKey)) {
      return _storedStreams[streamKey]! as Stream<ITimedSocketResponse<T>>;
    }
    final stream = _requestManager.decodedMessagesStream
        .where(
          (e) => e.topic.path == responsePath,
        )
        .map((event) => TimedMessage<T>.fromMessage(msg: event));

    _storedStreams[streamKey] = stream;

    return stream;
  }
}
