import 'dart:async';

import '../../../websocket_universal.dart';

/// asyncSocket.requestData(`socketTopic`)
abstract class IWebSocketRequestManager {
  /// Single messages
  Stream<ITimedSocketResponse> get decodedMessagesStream;

  /// Composite responses stream
  Stream<ICompositeSocketResponse> get finishedRequestsStream;

  /// Ping stream
  Stream<int> get pingMsStream;

  /// Last ping delay
  int get pingDelayMs;

  /// Send request to server
  void requestData(ISocketRequest socketRequest);

  /// Get cached server response
  ITimedSocketResponse? getStoredDecodedMessage(String key);

  /// Dispose
  void close();
}
