import '../interfaces/socket_topic.dart';

class SocketTopicImpl implements ISocketTopic {
  static const String pathDelimiter = '/';

  @override
  late final String path;
  @override
  late final List<String> pathSegments;

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

  SocketTopicImpl.onlyHost({required String host}) : this.path(fullPath: host);

  SocketTopicImpl.duo({required String host, required String topic1})
      : this(orderedPathSegments: [host, topic1]);

  SocketTopicImpl.trio({
    required String host,
    required String topic1,
    required String topic2,
  }) : this(orderedPathSegments: [host, topic1, topic2]);

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

ISocketTopic socketTopicFromJson(String fullPath) =>
    SocketTopicImpl.path(fullPath: fullPath);
String socketTopicToJson(ISocketTopic socketTopic) => socketTopic.path;
