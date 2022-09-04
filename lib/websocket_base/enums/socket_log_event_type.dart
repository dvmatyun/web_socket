enum SocketLogEventType {
  error('error'),
  warning('warning'),
  ping('ping'),
  pong('pong'),
  socketStateChanged('socketStateChanged'),
  toServerMessage('toServerMessage'),
  fromServerMessage('fromServerMessage');

  final String value;
  const SocketLogEventType(this.value);
}
