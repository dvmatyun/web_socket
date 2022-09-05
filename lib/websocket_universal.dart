/// Convenient websocket handler for all platforms (both IO and web/HTML).
/// Websocket messages routing, statuses and other features
/// have easy-to-use interface.

library websocket_universal;

/// Enums:
export 'src/websocket_base/enums/socket_log_event_type.dart';
export 'src/websocket_base/enums/socket_status_type.dart';

/// Interfaces:
export 'src/websocket_base/interfaces/message_processor.dart';
export 'src/websocket_base/interfaces/message_to_server.dart';
export 'src/websocket_base/interfaces/socket_log_event.dart';
export 'src/websocket_base/interfaces/socket_message.dart';
export 'src/websocket_base/interfaces/socket_state.dart';
export 'src/websocket_base/interfaces/socket_topic.dart';
export 'src/websocket_base/interfaces/websocket_handler.dart';

/// Models:
export 'src/websocket_base/models/message_to_server_impl.dart';
export 'src/websocket_base/models/socket_log_event_impl.dart';
export 'src/websocket_base/models/socket_message_impl.dart';
export 'src/websocket_base/models/socket_state_impl.dart';
export 'src/websocket_base/models/socket_topic_impl.dart';

/// Platform implementations:
export 'src/websocket_base/platform_implementation/platform_websocket.dart';

/// Services:
export 'src/websocket_base/services/socket_message_processor.dart';
export 'src/websocket_base/services/socket_simple_bytes_processor.dart';
export 'src/websocket_base/services/socket_simple_text_processor.dart';
