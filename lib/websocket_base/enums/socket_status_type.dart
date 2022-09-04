enum SocketStatus {
  disconnected('disconnected'),
  connecting('connecting'),
  connected('connected');

  final String value;
  const SocketStatus(this.value);
}
