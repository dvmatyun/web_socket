abstract class IMessageProcessor<T, Y> {
  T? deserializeMessage(Object? data);
  Object serializeMessage(Y message);

  /// Sending ping message to server:
  Object get pingServerMessage;

  /// Receiving pong message from server:
  bool isPongMessageReceived(T? data);
}
