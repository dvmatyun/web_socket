/// Event types for common events, happening in websockets
enum SocketLogEventType {
  /// Error occured
  error('error'),

  /// Warning
  warning('warning'),

  /// Pinging server
  ping('ping'),

  /// Getting answer to ping (getting pong from server)
  pong('pong'),

  /// Websocket connection state changed
  socketStateChanged('socketStateChanged'),

  /// Sending message to server
  toServerMessage('toServerMessage'),

  /// Getting message from server
  fromServerMessage('fromServerMessage'),

  /// Internal log message
  log('log');

  /// String value
  final String value;

  /// Constructor
  const SocketLogEventType(this.value);
}
