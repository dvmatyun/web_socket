/// Optional parameters for the webSocket connection
class SocketOptionalParams {
  /// Optional parameters for the webSocket connection
  const SocketOptionalParams({this.protocols, this.headers});

  /// ONLY FOR IO PLATFORM (Mobile, Desktop)
  /// THIS IS IGNORED IN WEB (HTML) PLATFORM
  final Iterable<String>? protocols;

  /// ONLY FOR IO PLATFORM (Mobile, Desktop)
  /// THIS HEADERS ARE IGNORED IN WEB (HTML) PLATFORM
  /// https://github.com/dart-lang/web_socket_channel/issues/156
  final Map<String, dynamic>? headers;
}
