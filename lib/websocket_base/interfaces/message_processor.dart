/// Websocket processor interface
/// for [T]-typed input messages from server
/// and [Y]-typed outgoing messages to server
abstract class IMessageProcessor<T, Y> {
  /// Deserialize message received from server
  T? deserializeMessage(Object? data);

  /// Serialize message to server
  Object serializeMessage(Y message);

  /// Sending ping message to server:
  Object get pingServerMessage;

  /// Receiving pong message from server:
  bool isPongMessageReceived(T? data);
}
