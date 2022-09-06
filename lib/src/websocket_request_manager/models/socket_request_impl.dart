import '../../../websocket_universal.dart';

class SocketRequest implements ISocketRequest {
  @override
  final ISocketMessage requestMessage;
  @override
  final int timeoutMs;
  @override
  final Set<ISocketTopic> responseTopics;

  const SocketRequest({
    required this.requestMessage,
    this.timeoutMs = 2000,
    this.responseTopics = const {},
  });
}
