import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../enums/socket_status_type.dart';
import 'platform_websocket.dart';

/// Factory for platform HTML ws client
IPlatformWebsocket createPlatformWsClient() => PlatformWebsocketHtml();

/// Platform HTML ws client
class PlatformWebsocketHtml implements IPlatformWebsocket {
  /// Platform specific:
  html.WebSocket? _webSocket;

  @override
  String? closeReason;

  @override
  Future<bool> connect(String url) async {
    _webSocket = html.WebSocket(url);
    await _webSocket?.onOpen.first;
    if (_webSocket?.readyState == html.WebSocket.OPEN) {
      return true;
    }
    return false;
  }

  @override
  void sendMessage(Object data) => _webSocket?.send(data);

  @override
  Stream get incomingMessagesStream {
    if (_webSocket == null) {
      throw Exception('Connection was not established yet!');
    }
    return _webSocket!.onMessage.asyncMap<Object?>((htmlMessage) async {
      final Object? input = htmlMessage.data;
      if (input is html.Blob) {
        final blob = input;
        final reader = html.FileReader();
        // ignore: cascade_invocations
        reader.readAsArrayBuffer(blob);
        await reader.onLoadEnd.first;
        final bytesList = reader.result as List<int>?;
        return bytesList;
      }
      return input;
    });
  }

  @override
  Future<void> close(int? code, String? reason) async {
    _webSocket?.close(code, reason);
  }

  @override
  String get platformStatus => '[IO  Platform status: ${_socketStatus()} ]';

  String _socketStatus() {
    if (_webSocket == null) {
      return "connection hasn't been opened yet!";
    }
    if (_webSocket?.readyState == html.WebSocket.OPEN) {
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
      case html.WebSocket.CONNECTING:
        return SocketStatus.connecting;
      case html.WebSocket.OPEN:
        return SocketStatus.connected;
      default:
        return SocketStatus.disconnected;
    }
  }
}
