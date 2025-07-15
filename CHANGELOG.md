# 1.3.0
- Now uses `dart:web` package instead of `dart:html`
- Highly recommend testing the library before using in production (report any issues you find)
- Updated dependencies

# 1.2.5
- Fixed checkout

# 1.2.4
- Fixed SocketOptionalParams export

# 1.2.3
- Added SocketOptionalParams to connect methods. (Only for IO platforms!)

# 1.2.2
- Meta constraint downgraded

# 1.2.1
- Upgraded dependencies

# 1.2.0
- Upgraded dependencies, minimum dart sdk version is 3.2.3 now

# 1.1.1
- IPlatformWebsocket is added as an optional parameter to interfaces

# 1.1.0
- Changed some constructors to allow more customization

# 1.0.1
- Restricted close message length for HTML webSocket

# 1.0.0
- Require dart 3.0
- updated dependencies

# 0.5.2
- socketStatus implementation for IO web socket improved

# 0.5.1
- updated dependencies (downgraded to meta: ^1.8.0)

# 0.5.0
- updated dependencies (to json_annotation: ^4.8.0 / meta: ^1.9.0)

# 0.4.2
- fix analyzer problems

# 0.4.1
- fix stackoverflow problem

# 0.4.0
- technical fixes and additional log message type added

# 0.3.7
- added reconnection timeout

# 0.3.6
- ping algorithm improves

# 0.3.5
- added `pingRestrictionForce` attribute to SocketConnectionOptions

# 0.3.4
- fixed error with re-requesting dart too many times
# 0.3.3
- readme and example fixes

# 0.3.2
- removed unused delay after connection

# 0.3.1
- added data re-request on reconnection event (only for SocketRequest messages)

# 0.3.0

- changed interfaces
- fixes

# 0.2.6

- hotfix

# 0.2.5

- hotfix
# 0.2.4

- data is Nullable now

# 0.2.3

- added `getResponsesStream` method

# 0.2.2

- Hotfix

# 0.2.1

- BaseDecoder added

# 0.2.0

- WebSocketRequestManager added
- WebSocketDataBridge added
- timeout for requests
- composite requests with multiple responses handling

# 0.1.1

- ping calculation changed
- SocketMessageProcessor ping/pong implementation changed

# 0.1.0

- working release
- added reconnection feature for `IWebSocketHandler`
- base socket functionality moved to `IWebSocketBaseService`

# 0.0.4-dev

- refactoring

# 0.0.3-dev

- now supports Byte array messages

# 0.0.2-dev

- refactor: rename library to `websocket_universal`
- exported required classes
- added example

# 0.0.1-dev

- added websocket implimentations for io and html

