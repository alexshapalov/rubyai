# Action Cable Protocol

[Action Cable](https://guides.rubyonrails.org/action_cable_overview.html) is a framework that allows you to integrate WebSockets with the rest of your Rails application easily.

It uses a simple JSON-based protocol for client-server communication.

AnyCable also implements an [extended version of the protocol](#action-cable-extended-protocol) to provide better consistency guarantees.

## Messages

Communication is based on messages. Every message is an object.

Protocol-related messages from server to client MUST have `type` field (string).

Possible types:

* [`welcome`]
* [`disconnect`]
* [`ping`]
* [`confirm_subscription`]
* [`reject_subscription`]

There are also _data_ messages–broadcasts and transmissions–they MUST have `message` field.

Protocol-related messages from client to server MUST have `command` field (string).

Possible commands:

* [`subscribe`]
* [`unsubscribe`]
* [`message`]

## Handshake

When client connects to server one of the following two could happen:

* server accepts the connection and responds with `welcome` message (`{"type":"welcome"}`)
* server rejects the connection and responds with a `disconnect` message, which may include fields `reason` and `reconnect` (`{"type":"disconnect", "reason":"unauthorized", "reconnect":false}`)\*

Server MUST respond with either a `welcome` message or a `disconnect` message.

\* `disconnect` message only exists in Rails 6.0 and later. Prior to 6.0, server would drop the connection without sending anything.

## Subscriptions & identifiers

Data messages, client-to-server messages and some server-to-client messages (`confirm_subscription`, `reject_subscription`) MUST contain `identifier` field (string) which is used to route data to the specified _channel_.

It's up to server and client how to generate and resolve identifiers.

Rails identifiers schema is the following: `{ channel: "MyChannelClass", **params }.to_json`.

For example, to subscribe to `ChatChannel` with `id: 42` client should send the following message:

```json
{
  "identifier": "{\"channel\":\"ChatChannel\",\"id\":42}",
  "command": "subscribe"
}
```

The response from server MUST contain the same identifier, e.g.:

```json
{
  "identifier": "{\"channel\":\"ChatChannel\",\"id\":42}",
  "type": "confirm_subscription"
}
```

To unsubscribe from the channel client should send the following message:

```json
{
  "identifier": "{\"channel\":\"ChatChannel\",\"id\":42}",
  "command": "unsubscribe"
}
```

There is no _unsubscription_ confirmation sent (see [PR#24900](https://github.com/rails/rails/pull/24900)).

## Receive messages

Data message from server to client MUST contain `identifier` field and `message` field with the data itself.

## Perform actions

_Action_ message from client to server MUST contain `command` ("message"), `identifier` fields, and `data` field containing a JSON-encoded value.

The `data` field MAY contain `action` field.

For example, in Rails to invoke a method on a channel class, you should send:

```json
{
  "identifier": "{\"channel\":\"ChatChannel\",\"id\":42}",
  "command": "message",
  "data": "{\"action\":\"speak\",\"text\":\"hello!\"}"
}
```

## Ping

Although [WebSocket protocol](https://tools.ietf.org/html/rfc6455#section-5.5.2) describes low-level `ping`/`pong` frames to detect dropped connections, some implementation (e.g. browsers) don't provide an API for using them.

That's why Action Cable protocol has its own, protocol-level pings support.

Server sends `ping` messages (`{ "type": "ping", "message": <Time.now.to_i>}`) every X seconds (3 seconds in Rails).

Client MAY track this messages and decide to re-connect if no `ping` messages have been observed in the last Y seconds.

For example, default Action Cable client reconnects if no `ping` messages have been received in 6 seconds.

## Action Cable Extended protocol

**NOTE:** This protocol extension is only supported by AnyCable-Go v1.4+.

The `actioncable-v1-ext-json` protocol adds new message types and extends the existing ones.

> You can find the example implementation of the protocol in the [anycable-client library](https://github.com/anycable/anycable-client/blob/master/packages/core/action_cable_ext/index.js).

### New command: `history`

The new command type is added, `history`. It is used by the client to request historical messages for the channel. It MUST contain the `identifier`, `command` ("history"), and `history` fields, where `history` contains the _history request_ object:

```js
{
  "identifier": "{\"channel\":\"ChatChannel\",\"id\":42}",
  "command": "history",
  "history": {
    "since": 1681828329,
    "streams": {
      "stream_id_1": {
        "offset": 32,
        "epoch": "x123"
      },
      "stream_id_2": {
        "offset": 54,
        "epoch": "x123"
      }
    }
  }
}
```

A history request contains two fields:

* `since` is a UNIX timestamp in seconds indicating the time since when to fetch the history. Optional. It is used only for streams with no offset specified (usually, during the initial subscription).

* `streams` is a map of stream IDs to observed offsets. Stream IDs, offsets, and epochs are received along with the messages. It's the responsibility of the client to track them and use for `history` requests. The `epoch` parameter specified the current state of the memory backend; if the current server's epoch doesn't match the requested one, the server fail to retrieve the history. For example, if in-memory backend is used to store streams history, every time a server restarts a new epoch starts.

In response to a `history` request, the server MUST respond with the requested historical messages (sent one by one, like during normal broadcasts, so the client shouldn't handle them specifically). Then, the server sends an acknowledgment message (`confirm_history`). If case messages couldn't be retrieved from the server (e.g., history has been evicted for a stream), the server MUST respond with the `reject_history` message.

### Requesting history during subscription

It's possible to request history along with the `subscribe` request by adding the `history` field to the command payload:

```js
{
  "identifier": "{\"channel\":\"ChatChannel\",\"id\":42}",
  "command": "subscribe",
  "history": {
    "since": 1681828329
  }
}
```

Usually, in this case we can only specify the `since` parameter.

In response, the server MUST first confirm the subscription and then execute the history request. If the subscription is rejected, no history request is made.

### New message types

Two new message types (server-client) are added:

* [`confirm_history`]
* [`reject_history`]

Both messages act as acknowledgments for the `history` command and contain the `identifier` key. The `confirm_history` message is sent to the client to indicate that the requested historical messages for the channel have been successfully sent to the client. The `reject_history` indicates that the server failed to retrieve the requested messages and no historical message have been sent (the client must implement a fallback mechanism to restore the consistency).

### Incoming messages extensions

Broadcasted messages MAY contain metadata regarding their position in the stream. This information MUST be used with the subsequent `history` requests:

```js
{
  "identifier": "{\"channel\":\"ChatChannel\",\"id\":42}",
  "message": {
    "text": "hello!",
    "user_id": 43
  },
  // NEW FIELDS:
  "stream_id": "chat_42",
  "epoch": "x123",
  "offset": 32
}
```

**NOTE:** The messages are not guaranteed to be in order (due to concurrent broadcasts), so, offsets may be non-monotonic. It's the client responsibility to keep track of offsets. Also, there is a small chance that the same message may arrive twice (from broadcast and from the history); to provide exactly-once delivery guarantees, the client MUST keep track of seen offsets and ignore duplicates.

### Handshake extensions

During the handshake, the server MAY send a unique _session id_ along with the welcome message:

```js
{
  "type": "welcome",
  "sid": "rcl245"
}
```

The client MAY use this ID during re-connection to restore the session state (subscriptions, channel states, etc.) and avoid re-subscribing to the channels. For that, the previously obtained session ID must be provided either as a query parameter (`?sid=rcl245`) or via an HTTP header (`X-ANYCABLE-RESTORE-SID`).

If the server's attempt to restore the session from the _sid_ succeeds, it MUST respond with the `welcome` message with the additional fields indicating that the session was restored:

```js
{
  "type": "welcome",
  "sid": "yi421", // Note that session ID has changed
  "restored": true,
  "restored_ids": [
    "{\"channel\":\"ChatChannel\",\"id\":42}"
  ]
}
```

The `restored` flag indicates whether the session state has been restored. **NOTE:** In this case, no `connect` method is invoked at the Action Cable side.

The optional `restored_ids` field contains the list of channel identifiers that has been re-subscribed automatically at the server side. The client MUST NOT try to resubscribe to the specified channels and consider them connected. It's recommended to perform `history` requests for all the restored channels to catch up with the messages.

### New command: `pong`

The `pong` command MAY be sent in response to the `ping` message if the server requires pongs. It could be used to improve broken connections detection.

### New command: `whisper` <img class='pro-badge' src='/assets/new.svg' alt='new' />

The `whisper` can be used to publish broadcast messages from the client (if the whisper stream has been configured for it) to a particular _channel_.

The payload MUST contain `command` ("whisper"), `identifier` fields, and `data` fields.

The `data` field MAY contain a string or an object.

For example:

```json
{
  "identifier": "{\"channel\":\"ChatChannel\",\"id\":42}",
  "command": "whisper",
  "data": {
    "event":"typing",
    "user":"Jack"
  }
}
```

**IMPORTANT**: Unlike actions (`message` command), the data is not JSON-serialized. It's broadcasted to connected clients as is.
