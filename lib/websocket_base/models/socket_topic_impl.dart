import '../interfaces/socket_topic.dart';

/// [ISocketTopic] implementation to route websocket message data.
/// Used same way as URL/URI in simple HTTP requests
class SocketTopicImpl implements ISocketTopic {
  /// Symbol that seprates [pathSegments] in [path]
  static const String pathDelimiter = '/';

  @override
  late final String path;
  @override
  late final List<String> pathSegments;

  /// Constructor where you path ordered path segments from major to minor.
  /// For example following list: <String>[host, topic1, topic2, topic3]
  /// Will result in [host/topic1/topic2/topic3] for [path] attribute
  SocketTopicImpl({required List<String> orderedPathSegments})
      : pathSegments = orderedPathSegments,
        path = orderedPathSegments.join(pathDelimiter);

  SocketTopicImpl.path({required String fullPath}) {
    var posLeft = 0;
    while (fullPath.length > (posLeft + 1) &&
        fullPath.substring(posLeft, posLeft + 1) == pathDelimiter) {
      posLeft++;
    }
    var posRight = fullPath.length;
    while (posRight > 1 &&
        fullPath.substring(posRight - 1, posRight) == pathDelimiter) {
      posRight--;
    }
    path = fullPath.substring(posLeft, posRight);
    pathSegments = path.split(pathDelimiter).toList(growable: false);
  }

  /// Constructor where topic [path] contains only [host]
  /// Will result in [host] for [path] attribute
  SocketTopicImpl.onlyHost({required String host}) : this.path(fullPath: host);

  /// Constructor where topic [path] contains [host] and [topic1]
  /// Will result in [host/topic1] for [path] attribute
  SocketTopicImpl.duo({required String host, required String topic1})
      : this(orderedPathSegments: [host, topic1]);

  /// Constructor where topic [path] contains [host], [topic1], [topic2]
  /// Will result in [host/topic1/topic2] for [path] attribute
  SocketTopicImpl.trio({
    required String host,
    required String topic1,
    required String topic2,
  }) : this(orderedPathSegments: [host, topic1, topic2]);

  /// Constructor where topic [path]
  /// contains [host], [topic1], [topic2], [topic3]
  /// Will result in [host/topic1/topic2/topic3] for [path] attribute
  SocketTopicImpl.four({
    required String host,
    required String topic1,
    required String topic2,
    required String topic3,
  }) : this(orderedPathSegments: [host, topic1, topic2, topic3]);

  @override
  String get host => pathSegments[0];

  @override
  String get topic1 => pathSegments.length > 1 ? pathSegments[1] : '';

  @override
  String get topic2 => pathSegments.length > 2 ? pathSegments[2] : '';

  @override
  String get topic3 => pathSegments.length > 3 ? pathSegments[3] : '';

  @override
  String toString() => path;
}

/// Deserialize [ISocketTopic] from JSON.
/// From server expected String of the following format:
/// 'host/topic1/topic2/topic3' (without quotes)
/// Example of usage with 'json_annotation' package:
/// @JsonKey(fromJson: socketTopicFromJson, toJson: socketTopicToJson)
/// final ISocketTopic topic;
ISocketTopic socketTopicFromJson(String fullPath) =>
    SocketTopicImpl.path(fullPath: fullPath);

/// Serialize [ISocketTopic] to JSON string.
/// Server will receive serialized topic of the following format:
/// 'host/topic1/topic2/topic3' (without quotes)
/// Example of usage with 'json_annotation' package:
/// @JsonKey(fromJson: socketTopicFromJson, toJson: socketTopicToJson)
/// final ISocketTopic topic;
String socketTopicToJson(ISocketTopic socketTopic) => socketTopic.path;
