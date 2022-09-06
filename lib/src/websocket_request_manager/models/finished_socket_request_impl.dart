import '../../../websocket_universal.dart';

class FinishedSocketRequest implements IFinishedSocketRequest {
  @override
  final ISocketRequest socketRequest;
  @override
  final DateTime timeRequested;

  @override
  final int msElapsed;
  final Map<String, Object> dataDictionary;

  @override
  T getData<T>() {
    for (final d in dataDictionary.values) {
      if (d is T) {
        return d as T;
      }
    }
    throw Exception('Data of requested type ${T.toString()} not found!');
  }

  FinishedSocketRequest({
    required TimeoutSocketRequest request,
    required this.dataDictionary,
  })  : socketRequest = request.socketRequest,
        timeRequested = request.timeRequested,
        msElapsed = request.msElapsed;

  @override
  // TODO: implement responses
  Map<String, ISocketMessage> get responses => throw UnimplementedError();
}
