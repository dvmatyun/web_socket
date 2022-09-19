import '../../../websocket_universal.dart';

/// Composite response that is result of [ISocketRequest] with multiple
/// `responseTopics`
abstract class ICompositeSocketResponse {
  /// Origin socket request
  ISocketRequest get socketRequest;

  /// Data received from server
  Map<String, Object?> get dataCached;

  /// When request was initiated
  DateTime get timeRequested;

  /// Time elapsed between request and response
  int get msElapsed;

  /// Get data from [dataCached] that is [T]-typed
  T getData<T>();
}
