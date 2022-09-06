import 'dart:io' as io;

import '../enums/socket_status_type.dart';
import 'platform_websocket.dart';

/// Factory for platform IO ws client
IPlatformWebsocket createPlatformWsClient() => PlatformWebsocketIo();

/// Platform IO ws client
class PlatformWebsocketIo implements IPlatformWebsocket {
  /// Platform specific:
  io.WebSocket? _webSocket;
  static const String _platform = 'IO ';

  @override
  String? get closeReason => _webSocket?.closeReason;

  @override
  Future<bool> connect(String url) async {
    var connectUrl = url;
    if (io.Platform.isAndroid) {
      connectUrl = connectUrl.replaceAll('127.0.0.1', '10.0.2.2');
    }
    _webSocket = await io.WebSocket.connect(connectUrl);
    if (_webSocket?.readyState == 1) {
      return true;
    }
    return false;
  }

  @override
  void sendMessage(Object data) => _webSocket?.add(data);

  @override
  Stream<Object?> get incomingMessagesStream {
    if (_webSocket == null) {
      throw Exception('Connection was not established yet!');
    }
    return _webSocket!;
  }

  @override
  Future<void> close(int? code, String? reason) async {
    await _webSocket?.close(code, reason);
  }

  @override
  String get platformStatus =>
      '[$_platform Platform status: ${_socketStatus()} ]';

  String _socketStatus() {
    if (_webSocket == null) {
      return "webSocket connection hasn't been opened yet!";
    }
    if (_webSocket?.closeCode == null && _webSocket?.closeReason == null) {
      return 'connection opened';
    }
    return 'close_code= ${_webSocket?.closeCode}, '
        'close_reason= ${_webSocket?.closeReason}';
  }

  @override
  SocketStatus get socketStatus {
    if (_webSocket?.readyState == 1) {
      return SocketStatus.connected;
    }
    return SocketStatus.disconnected;
  }
}
