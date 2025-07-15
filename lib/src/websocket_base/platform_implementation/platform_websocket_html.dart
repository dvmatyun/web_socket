import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../enums/socket_status_type.dart';
import '../models/socket_optional_params.dart';
import 'platform_websocket.dart';
import 'utils.dart';

/// Factory for platform HTML ws client
IPlatformWebsocket createPlatformWsClient() => PlatformWebsocketHtml();

/// Platform HTML ws client
class PlatformWebsocketHtml implements IPlatformWebsocket {
  /// Platform specific:
  web.WebSocket? _webSocket;
  static const String _platform = 'Web';

  @override
  String? closeReason;

  @override
  Future<bool> connect(
    String url,
    Duration timeout, {
    SocketOptionalParams params = const SocketOptionalParams(),
  }) async {
    _webSocket = web.WebSocket(url);
    await _webSocket?.onOpen.first.timeout(timeout);
    if (_webSocket?.readyState == web.WebSocket.OPEN) {
      return true;
    }
    return false;
  }

  @override
  void sendMessage(Object data) => _webSocket?.send(data.jsify()!);

  @override
  Stream get incomingMessagesStream {
    final ws = _webSocket;
    if (ws == null) {
      throw Exception('Connection was not established yet!');
    }
    return ws.onMessage.asyncMap<Object?>((htmlMessage) async {
      final eventData = htmlMessage.data;
      if (eventData == null) return null;
      if (eventData.typeofEquals('string')) {
        return (eventData as JSString).toDart;
      }
      if (eventData.typeofEquals('object') &&
          (eventData as JSObject).instanceOfString('ArrayBuffer')) {
        final bytes = (eventData as JSArrayBuffer).toDart.asUint8List();
        return bytes;
      }

      return eventData;
    });
  }

  @override
  Future<void> close(int? code, String? reason) async {
    final reasonNotNull = reason ?? '?';
    checkCloseCode(code);

    _webSocket?.close(
      code ?? 1000,
      // HTML socket has restriction on message length in bytes (123 byte?)
      reasonNotNull.length > 5 ? reasonNotNull.substring(0, 5) : reasonNotNull,
    );
  }

  @override
  String get platformStatus =>
      '[$_platform Platform status: ${_socketStatus()} ]';

  String _socketStatus() {
    if (_webSocket == null) {
      return "connection hasn't been opened yet!";
    }
    if (_webSocket?.readyState == web.WebSocket.OPEN) {
      return 'connection opened';
    }
    return 'connection closed';
  }

  @override
  SocketStatus get socketStatus {
    if (_webSocket == null) {
      return SocketStatus.disconnected;
    }
    switch (_webSocket?.readyState ?? -1) {
      case web.WebSocket.CONNECTING:
        return SocketStatus.connecting;
      case web.WebSocket.OPEN:
        return SocketStatus.connected;
      default:
        return SocketStatus.disconnected;
    }
  }
}
