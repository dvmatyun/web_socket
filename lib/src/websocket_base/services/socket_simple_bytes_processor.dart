import 'dart:convert';

import '../../../websocket_universal.dart';

/// IMessageProcessor that sends to and
/// receives 'List<int>' bytes array from Server
class SocketSimpleBytesProcessor
    implements IMessageProcessor<List<int>, List<int>> {
  @override
  List<int>? deserializeMessage(Object? data) {
    if (data is List<int>) {
      final copiedList = [...data]..removeWhere((e) => e == 0);
      return copiedList;
    }
    if (data is String) {
      return utf8.encode(data);
    }
    return null;
  }

  @override
  bool isPongMessageReceived(Object? data) {
    if (data is List<int>) {
      final copiedList = [...data]..removeWhere((e) => e == 0);
      final decoded = utf8.decode(copiedList);
      if (['ping', 'pong'].contains(decoded)) {
        return true;
      }
    }
    if (data is String) {
      if (['ping', 'pong'].contains(data)) {
        return true;
      }
    }

    return false;
  }

  late final _pingMessage = utf8.encode('ping');
  @override
  Object get pingServerMessage => _pingMessage;

  @override
  Object serializeMessage(List<int> message) => message;
}
