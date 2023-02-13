import '../../../websocket_universal.dart';

/// Composite server response implemntation
class CompositeSocketResponse implements ICompositeSocketResponse {
  @override
  final ISocketRequest socketRequest;
  @override
  final DateTime timeRequested;
  @override
  final Map<String, Object?> dataCached;
  @override
  final int msElapsed;

  @override
  T getData<T>() {
    for (final d in dataCached.values) {
      if (d is T) {
        return d;
      }
    }
    throw Exception('Data of requested type $T not found!');
  }

  /// Constructor
  CompositeSocketResponse({
    required TimeoutSocketRequest request,
    required this.dataCached,
  })  : socketRequest = request,
        timeRequested = request.timeRequested,
        msElapsed = request.msElapsed;
}
