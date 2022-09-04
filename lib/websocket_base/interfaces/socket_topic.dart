abstract class ISocketTopic {
  /// Full topic path.
  /// Example: [host/segmentOne] or [host/segmentOne/segmentTwo/segmentThree]
  /// Another example: [menu/get-online]
  String get path;

  /// List of path segments:
  /// pathSegments[0] == host
  /// pathSegments[1] == topic1
  List<String> get pathSegments;

  /// First param in topic. host == pathSegments[0]
  String get host;

  /// Second param in topic. topic1 == pathSegments[1] (or empty string if not exists)
  String get topic1;

  /// topic2 == pathSegments[2] (or empty string if not exists)
  String get topic2;

  /// topic3 == pathSegments[3] (or empty string if not exists)
  String get topic3;
}
