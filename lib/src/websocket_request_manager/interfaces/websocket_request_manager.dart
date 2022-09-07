import 'dart:async';

import '../../../websocket_universal.dart';

/// asyncSocket.requestData(`socketTopic`)
abstract class IWebSocketRequestManager {
  Stream<ITimedMessage> get decodedMessagesStream;
  Stream<IFinishedSocketRequest> get finishedRequestsStream;
  Stream<int> get pingMsStream;

  void requestData(ISocketRequest socketRequest);
  ITimedMessage? getStoredDecodedMessage(String key);

  void close();
}
