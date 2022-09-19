import '../../../websocket_universal.dart';

/// Grouped reponse data to `ISocketRequest`
abstract class ISocketResponse {
  /// original request
  ISocketMessage get requestMessage;

  /// aggregated responses
  List<ISocketMessage> get responses;
}
