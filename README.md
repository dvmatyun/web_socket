# websocket_universal
[![CHECKOUT](https://github.com/dvmatyun/web_socket/actions/workflows/checkout.yml/badge.svg)](https://github.com/dvmatyun/web_socket/actions/workflows/checkout.yml)

## Easy-to-use interface:
1. Only [connect()] and [disconnect()] methods to use websocket handler!
2. Send message to server using [sendMessage(Y messageToServer)] and
listen messages coming from server using [incomingMessagesStream]
3. Listen to websocket states [socketStateStream] 
or all events that are happening [logEventStream].
Define how you process your messages to and from server and ping/pong interaction
using [IMessageProcessor<Tin,Yout>] generic interface or use convinient
[SocketMessageProcessor] implementation (see example).