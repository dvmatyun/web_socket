import '../../../websocket_universal.dart';
import 'platform_websocket_io.dart'
    if (dart.library.html) 'platform_websocket_html.dart';

/// Universal platform websocket implementation
abstract class IPlatformWebsocket {
  /// Platform webSocket status in readable format
  String get platformStatus;

  /// Stream of messages from server
  Stream<Object?> get incomingMessagesStream;

  /// Current platform webSocket status
  SocketStatus get socketStatus;

  /// Close reason
  String? get closeReason;

  /// Connect to server (websocket)
  Future<bool> connect(String url, Duration timeout);

  /// Send message to server
  void sendMessage(Object data);

  /// Close connection
  Future<void> close(int? code, String? reason);

  /// Create universal webSocket client
  factory IPlatformWebsocket.createPlatformWsClient() =>
      createPlatformWsClient();
}
