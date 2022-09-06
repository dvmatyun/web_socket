import 'dart:async';

import '../../../websocket_universal.dart';

/// Middleware that uses `webSocketHandler.sendMessage`
/// to send message to server
typedef SendSocketMessageFunc = void Function(
  ISocketMessage socketMessage,
  IWebSocketHandler<ISocketMessage, ISocketMessage> webSocketHandler,
);

/// Middleware that decodes messages from server
typedef DecodeSocketMessageFunc = Object? Function(
  ISocketMessage socketMessage,
);

/// asyncSocket.requestData(`socketTopic`)
abstract class IWebSocketRequestManager {
  Stream<ITimedMessage> get decodedMessagesStream;
  Stream<IFinishedSocketRequest> get finishedRequestsStream;
  Stream<int> get pingMsStream;

  void requestData(ISocketRequest socketRequest);
  ITimedMessage? getStoredDecodedMessage(String key);

  void close();
}
