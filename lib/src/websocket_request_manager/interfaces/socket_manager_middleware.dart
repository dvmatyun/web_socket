import '../../../websocket_universal.dart';

/// Middleware between socket handler and manager
abstract class ISocketManagerMiddleware {
  /// Decode result must be typed payload
  Object? decodeSocketMessage(ISocketMessage socketMessage);

  /// Do some actions before sending to server
  ISocketMessage encodeSocketMessage(ISocketMessage socketMessage);
}
