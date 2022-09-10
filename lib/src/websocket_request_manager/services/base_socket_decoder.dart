import 'dart:convert';

import '../../../websocket_universal.dart';

/// Base decoder helper
class BaseDecode {
  /// Decode single entity
  Map<String, Object?> tryDecodeSingle(
    ISocketMessage source, {
    String calledBy = '-',
  }) {
    if (source.data is! String) {
      throw ArgumentError(
        "[tryDecodeSingle Error] Can't decode single message for "
        "topic: '${source.topic}'. Data is not String! Called by [$calledBy]",
      );
    }

    final Object? data = jsonDecode(source.data as String);
    if (data is Map<String, Object?>) {
      return data;
    }
    throw ArgumentError(
      "[tryDecodeSingle Error] Can't decode single message for "
      "topic: '${source.topic}'. jsonDecode failed! Called by [$calledBy]",
    );
  }

  /// Decode list of entities
  List<Map<String, Object?>> tryDecodeList(
    ISocketMessage source, {
    String calledBy = '-',
  }) {
    if (source.data is! String) {
      throw ArgumentError(
        "[tryDecodeList Error] Can't decode LIST message for "
        "topic: '${source.topic}'. Data is not String! Called by [$calledBy]",
      );
    }
    try {
      final data = jsonDecode(source.data as String) as List<dynamic>;
      return data
          .map((dynamic e) => e as Map<String, Object?>)
          .toList(growable: false);
    } on Object catch (_) {
      throw ArgumentError(
        "[tryDecodeList Error] Can't decode LIST message for "
        "topic: '${source.topic}'. Called by [$calledBy] jsonDecode failed!",
      );
    }
  }
}
