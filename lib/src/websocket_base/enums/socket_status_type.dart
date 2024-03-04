/// Websocket connection status
enum SocketStatus {
  /// Disconnected
  disconnected('disconnected'),

  /// Connecting
  connecting('connecting'),

  /// Connected
  connected('connected');

  /// String value
  final String value;

  /// Default constructor
  const SocketStatus(this.value);
}
