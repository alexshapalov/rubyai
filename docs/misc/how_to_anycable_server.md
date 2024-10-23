# Writing Custom AnyCable Server

You can write your own server to handle _cable clients_ and connect them to your business logic through AnyCable.

Saying "cable clients" we want to underline that AnyCable doesn't depend on any transport protocol (e.g., WebSockets), you can use any protocol for client-server communication (e.g., RTMP, custom TCP, long-polling, etc.).

## Requirements

The server should be able to:

- Communicate with [gRPC](https://grpc.io) server as a gRPC client

gRPC provides libraries for most popular languages (see [docs](http://www.grpc.io/docs/)).

If there is no gRPC support for your favorite language, you can build it yourself (the minimal implementation for AnyCable)–it's just HTTP2 + [Protocol Buffers](https://developers.google.com/protocol-buffers/).

See [erlgrpc](https://github.com/palkan/erlgrpc) for the example of a minimal gRPC client.

- Subscribe to Redis channels.

We use Redis to receive broadcast events from the application by default (see [Broadcast adapters](../ruby/broadcast_adapters.md)).

**NOTE**: You can build a custom broadcast adapter (for both–your server and `anycable`  gem).
For the rest of this article, we consider that we want to use Redis.

## Step-by-step

Let's go through all steps to implement a custom server (using abstract language).

### Step 1. Server

First of all, you need a _server_–the entry point for clients connections – which can handle incoming data and disconnection events.

```js
interface Server {
 # Invoked on socket connection.
 # socket_handle is an entity (object/record/whatever) representing connection socket
 func socket_conn(socket_handle);

 # Invoked on socket disconnection
 func socket_disconn(socket_handle);

 # Invoker on incoming message
 func socket_data(socket_handle, msg);
}
```

### Step 2. Hub

_Hub_ stores information about clients subscriptions and has the following interface:

```js
interface Hub {
  # Subscribe socket to the stream.
  # We also need a channel_id to sign messages with it (see below)
  func add(socket_handle, channel_id, stream);

  # Unsubscribe socket from a stream for the given channel
  func remove(socket_handle, channel_id, stream);

   # Unsubscribe socket from all streams for the given channel
  func removeAll(socket_handle, channel_id);

  # Broadcast a message to all subscribed sockets
  func broadcast(stream, msg);
}
```

Why do we need a `channel_id`? This is required by Action Cable client.
The JS client doesn't know about streams, only about channels. So it needs a channel identifier to be present in incoming messages to resolve channels.

Moreover, there are no uniqueness restrictions on streams names–the same stream name can be used for different channels.

Thus, our `broadcast` function may look like this:

```js
func broadcast(stream, msg) {
  # Assume that we have a nested structure to store subscriptions:
  # sockets2streams
  #           |
  #           stream1
  #           |    |
  #           |    channel1 - (socket1, ..., socketN)
  #           |    |
  #           |    channel2 – ( ... )
  #           |
  #           stream2 ...
  #
  for (channel in channels_for_stream(stream)) {
    channel_msg = msg_for_channel(msg, channel.id())
    for (socket in channel.sockets()) {
      socket.transmit(channel_msg)
    }
  }
}

# msg – JSON encoded string
# We should transform into another JSON "{"identifier":<identifier>,"message": <msg>}"
func msg_for_channel(msg, identifier) {
  return json_encode(['identifier', 'message'], [identifier, json_decode(msg)]);
}
```

### Step 3. Pinger

Action Cable clients assume that a server sends a special message–ping–every 3 seconds (configurable).
Thus we should implement a _pinger_.

Pinger is a simple entity that holds a list of active sockets and broadcast a message to them every X seconds.

```js
interface Pinger {
  # Add socket to the active list
  func register(socket_handle);

  # Remove socket from the active list
  func unregister(socket_handle);
}
```

And we need a kind of `loop` method:

```js
func loop() {
  while(true) {
    var msg = ping_message()
    for (socket in active_sockets) {
      socket.transmit(msg)
    }
    sleep(INTERVAL)
  }
}


func ping_message() {
  return json_encode(['type', 'message'], ['ping', time.utc()])
}
```

**NOTE**: _ping_ could be implemented in a different way (e.g. via a timer attached to a _client_ session).

### Step 4. gRPC Client

Then you have to build a gRPC client using a [Protobuf service definition](rpc_proto.md).

It has a simple interface with only three methods: `Connect`, `Disconnect` and `Command`.
Let's go to Step 5 to see, how to use these methods and their return values.

### Step 5. Server – RPC communication

Now, when we already have a server and RPC client, let's fit them together.

**NOTE**: see also [Action Cable protocol spec](action_cable_protocol.md).

#### Client Connection

Every time a client is connected to our server we should invoke `Connect` method to authorize connection:

```js
func socket_conn(socket_handle) {
  # We need request URL and cookies (if we want to use cookie-based authentication)
  var url = socket_handle.url()
  # Extract Cookie header and build a map { 'Cookie' => cookie_val }
  # NOTE: you MAY provide more headers if you want
  var headers = header('Cookie', socket_handle.header('Cookie'));

  # Keep header for subsequent calls
  socket_handle.setFilteredHeaders(headers);

  # Then generate a payload (build protobuf msg)
  # ConnectionRequest contains fields:
  #   env:
  #     url - string - request URL
  #     headers - map<string><string>
  var env = pb::SessionEnv(url, headers)
  var payload = pb::ConnectionRequest(env)

  # Make a call and get a response – ConnectionResponse:
  #    status – Status::SUCCESS | Status::ERROR – status enum is a part of rpc.proto
  #    identifiers – string (connection identifiers string used by the app)
  #    transmissions - list of strings (repeated string)
  var response = rpc::Connect(payload)

  # handle response
  if (response.status() == pb::Status::SUCCESS) {
    # store identifiers for the socket
    # we will use them in later calls
    socket_handle.setIdentifiers(response.identifiers())

    # update a client's connection state
    socket_handle.setState(response.env().cstate())

    # transmit messages to socket
    # NOTE: typically Connect returns only "welcome" message
    socket_handle.transmit(response.transmissions())

    # register socket to pinger
    pinger.register(socket_handle)
  } else {
    # if Status is not SUCCESS we should disconnect the socket
    socket_handle.close()

    # non-SUCCESS status could be:
    #  - ERROR - there was an en exception during the call; in this case we also have response.error_msg()
    #  - FAILURE - application-level "rejection" (e.g. authentication failed)
  }
}
```

#### Client Commands

_Command_ is an incoming message from the client.
We should distinguish "subscribe" and "unsubscribe" command from others, 'cause they're responsible for subscriptions.

```js
func socket_data(socket_handle, msg) {
  var decoded = json_decode(msg)
  var type = decoded.key("type")
  # Every command is associated with the specified channel
  var identifier = decoded.key("identifier")
  var data = decoded.key("data")

  # Generate a payload (build protobuf msg)
  # CommandMessage contains fields:
  #   command - string
  #   identifier - string (channel identifier)
  #   connection_identifiers - string (identifiers from Connect call)
  #   data – string (additional provided data)
  #   env:
  #     url - string - request URL
  #     headers - map<string><string>
  #     cstate - map<string><string> — connection state obtained in socket_conn
  #     istate - map<string><string> — channel state for the identifier
  var env = pb::SessionEnv(socket_handle.url(), socket.filtered_headers(), socket.state(), socket.channel_state(identifier))
  var payload = pb::CommandMessage(type, identifier, socket_handle.identifiers(), data, env)

  # Make a call and get a response – ConnectionResponse:
  #    status – Status::SUCCESS | Status::FAILURE | Status::ERROR– status enum is a part of rpc.proto
  #    disconnect – bool – whether to disconnect the client or not
  #    stop_streams – bool – whether to stop all existing subscriptions for the channel
  #    streams – list of strings – new subscriptions
  #    stopped_streams - list of strings —
  #    transmissions - list of strings – messages to send to the client
  #    error_msg – error message in case of ERROR
  #    env:
  #      cstate - map<string><string> — connection state changed/new fields
  #      istate — map<string><string> — channel state changed/new fields
  var response = rpc::Command(payload)

  # handle response
  if (response.status() == pb::Status::SUCCESS) {
    # First, handle subscription commands
    # We should track client subscriptions in order to call `#unsubscribe` callbacks on disconnection
    if (type == "subscribe") {
      socket_handle.addSubscripton(identifier)
    }

    if (type == "unsubscribe") {
      socket_handle.removeSubscription(identifier)
    }

    # Then handle other response information
    # If response contains disconnect flag set to true
    # The we immediately disconnect the client
    if (response.disconnect()) {
      return socket_handle.close()
    }

    # update connection state
    if (response.env().cstate()) {
      socket_handle.mergeState(response.env().cstate())
    }

    # update channel state
    if (response.env().istate()) {
      # socket_handle.channel_state has a form of map<string><map<string><string>>,
      # where first-level keys are subscription identifiers, and values are the
      # corresponding channels states
      socket_handle.mergeChannelState(identifier, response.env().istate())
    }

    if (response.stop_streams()) {
      # Stop all subscriptions for the channel
      hub.removeAll(socket_handle, identifier)
    }

    # Add new subscriptions
    for (stream in response.streams()) {
      hub.add(socket_handle, identifier, stream)
    }

    # Remove old subscriptions
    for (stream in response.stopped_streams()) {
      hub.add(socket_handle, identifier, stream)
    }

    # And, finally, transmit messages
    socket_handle.transmit(response.transmissions())
  } else {
    # in case of failure you may want to disconnect the client
    socket_handle.close()
  }
}
```

#### Client Disconnection

When a client disconnects, we should remove its subscriptions, de-register from pinger and invoke `#disconnect`/`#unsubscribe` callbacks in the app.

```js
func socket_disconn(socket_handle) {
  # De-register socket from pinger
  pinger.unregister(socket_handle)

  # Remove subscriptions
  var subscriptions = socket_handle.subscriptions()

  for (channel in subscriptions) {
    hub.removeAll(socket_handle, channel)
  }

  # And only after that notify the app thru RPC

  # Then generate a payload (build protobuf msg)
  # DisconnectRequest contains fields:
  #  identifiers – string – connection identifiers
  #  subscriptions – list of strings – connections channels
  #  env:
  #    url – string – request URL
  #    headers - map<string><string>
  #    cstate - map<string><string> — connection state
  #    istate - map<string><string> — channel states for all subscriptions

  # We need to encode channel states to strings to pass them as istate (which is a string-string map)
  var channel_states = socket.channel_state().transform_values( (v) => JSON.encode(v) )

  var env = pb::SessionEnv(socket_handle.url(), socket.filtered_headers(), socket.state(), channel_states)
  var payload = pb::DisconnectRequest(socket_handle.identifier(), subscriptions, env)

  # Make a call and get a response – DisconnectResponse:
  #    status – Status::SUCCESS | Status::ERROR – status enum is a part of rpc.proto
  # Actually, response status does not matter here, we should cleanup
  rpc::Disconnect(payload)
}
```

**NOTE**: It makes sense to call `Disconnect` asynchronously or using a queue in order to avoid RPC calls spikes caused by mass-disconnection.

### Step 6. Testing

You can use [AnyT](https://github.com/anycable/anyt)–AnyCable conformance testing tool–for integration tests.
