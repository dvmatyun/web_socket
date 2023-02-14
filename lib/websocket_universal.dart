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
export 'src/websocket_base/interfaces/websocket_base_service.dart';

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
export 'src/websocket_base/services/websocket_base_service_impl.dart';
export 'src/websocket_handler/interfaces/websocket_handler.dart';
export 'src/websocket_handler/models/socket_connection_options.dart';

/// Websocket Request manager Interfaces:
export 'src/websocket_request_manager/interfaces/composite_socket_response.dart';
export 'src/websocket_request_manager/interfaces/socket_manager_middleware.dart';
export 'src/websocket_request_manager/interfaces/socket_request.dart';
export 'src/websocket_request_manager/interfaces/socket_response.dart';
export 'src/websocket_request_manager/interfaces/timed_socket_response.dart';
export 'src/websocket_request_manager/interfaces/websocket_data_bridge.dart';
export 'src/websocket_request_manager/interfaces/websocket_request_manager.dart';
export 'src/websocket_request_manager/models/composite_socket_response_impl.dart';
export 'src/websocket_request_manager/models/custom_game_model.dart';

/// Websocket Request manager Models:
export 'src/websocket_request_manager/models/socket_request_impl.dart';
export 'src/websocket_request_manager/models/timed_message_impl.dart';
export 'src/websocket_request_manager/models/timeout_socket_request.dart';
export 'src/websocket_request_manager/services/base_socket_decoder.dart';

/// Websocket Request manager Services:
export 'src/websocket_request_manager/services/socket_manager_middleware_impl.dart';
export 'src/websocket_request_manager/services/websocket_data_bridge_impl.dart';
export 'src/websocket_request_manager/services/websocket_request_manager_impl.dart';
