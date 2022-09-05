/// WebSocketHandler behaviour options
class SocketConnectionOptions {
  /// [timeoutConnectionMs] milliseconds timeout for establishing a connection
  final int timeoutConnectionMs;

  /// Ping server with custom message every [pingIntervalMs] milliseconds
  /// Ping/pong messages are defined in `IMessageProcessor` class
  final int pingIntervalMs;

  /// If [skipPingMessages] is FALSE then PING/PONG messages will be added to
  /// `outgoingMessagesStream` and `incomingMessagesStream` streams.
  final bool skipPingMessages;

  /// How many times webSocket handler may fail reconnection attempts
  /// in a row. Resets on successful connection.
  /// Reconnection is disabled on null.
  final int? failedReconnectionAttemptsLimit;

  /// How many auto-reconnection attempts may be made every minute.
  /// Inifnite on null.
  final int? maxReconnectionAttemptsPerMinute;

  /// Constructor
  const SocketConnectionOptions({
    this.timeoutConnectionMs = 5000,
    this.pingIntervalMs = 2000,
    this.skipPingMessages = true,
    this.failedReconnectionAttemptsLimit = 5,
    this.maxReconnectionAttemptsPerMinute = 20,
  });
}
