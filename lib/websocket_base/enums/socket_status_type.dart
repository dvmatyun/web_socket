/// Websocket connection status
enum SocketStatus {
  /// Disconnected
  disconnected('disconnected'),

  /// Connecting
  connecting('connecting'),

  /// Connected
  connected('connected');

  /// {@nodoc}
  final String value;

  /// {@nodoc}
  const SocketStatus(this.value);
}
