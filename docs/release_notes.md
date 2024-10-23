# Release Notes

This page contains combined release notes for major and minor releases of all AnyCable libraries.

## 1.5.0

### Highlights

- **Signed streams and public streams**

  We made signed streams functionality previously available for Hotwire applications (Turbo Streams) generic and available to everyone. Thus, it's now possible to use AnyCable without RPC as a regular pub/sub server with plain channels (but with all other features, like reliability, available 😉).

  This feature also comes with the initial support for **client-initiated broadcasts**, or _whispers_.

  See [docs](/anycable-go/signed_streams).

- **One secret to rule them all**

  Now a single secret is enough to secure all AnyCable features; we call it an **application secret**. You can provide it via the `--secret` flag or the `ANYCABLE_SECRET=<val>` env var. It's used as is for JWT and signed streams (unless specific secrets specified) and as a secret base for HTTP RPC and HTTP broadcasting (again, unless specific keys specified).

  There is also new `--broadast_key` (`ANYCABLE_BROADCAST_KEY`) that is meant to be used to authenticate broadcast actions. Currently, it's only used by HTTP broadcasting (as a replacement for `http_broadcast_secret`).

### Features

- **Public mode**.

  You can run AnyCable in an insecure mode (at your own risk): no authentication (unless JWT specified), public streams, no HTTP broadcasting authentication. You can enable this mode via the `--public` toggle or by setting `ANYCABLE_PUBLIC=true`.

  It's also possible to partially disable protections via `--noauth` and `--public_streams` parameters.

- **Embedding**.

  AnyCable Go library now provides interface that allows you to embed an AnyCable server into an existing Go web applications and use its HTTP handlers (for WebSockets, SSE, broadcasting).

  See [docs](https://docs.anycable.io/edge/anycable-go/library?id=embedding).

#### Rails

- Added `websocket_url` parameter to provide a WebSocket server address for clients.

  This new parameter automatically updates the `config.action_cable.url` to provide the WebSocket server information to clients via the `#action_cable_meta_tag` (or `#action_cable_with_jwt_meta_tag`) helpers. Thus, all you need to point your clients to AnyCable is configure the `websocket_url` (or `ANYCABLE_WEBSOCKET_URL`) value, no code changes required.

- Broadcasting to objects.

  Extended `ActionCable.server.broadcast` to accept not only strings but objects (similar to `Channel.broadcast_to(...)`).

  See [docs](/rails/extensions?id=broadcast-to-objects).

- Whispering support.

  You can specify the whispering stream (for client-initiated broadcasts) by using the `#stream_from(..., whisper: true)` or `#stream_for(..., whisper: true)` in your channel classes.

   See [docs](/rails/extensions?id=whispering).

- Added `rails g anycable:bin`.

  This generator creates a `bin/anycable-go` script to run (and install) AnyCable server locally.

### Changes

#### AnyCable server

- Logging format has changed.

  We migrated to Go `log/slog` package for performance and DX reasons and decided to stick to the default Go log formatting.

- HTTP broadcasting endpoint is enabled by default.

  Depending on security settings (whether the application secret or broadcast key is present), we expose HTTP broadcasting endpoint on the main application port (when secured) or `:8090` (when no authentication required, previous behaviour).

- Multiple configuration parameters name changes.

  You will see deprecation warning on the server start with instructions on how to migrate.

#### AnyCable Ruby/Rails

- The `anycable-rails-jwt` gem has been merged into the `anycable` and `anycable-rails` gems.

## 1.4.0

### Highlights

- **Reliable streams and resumable sessions**.

  AnyCable-Go improves data consistency of your real-time applications by allowing clients to request the missed messages on re-connection and restore their state without re-authentication and re-subscription to channels.

  The features require using the [extended version of Action Cable protocol](./misc/action_cable_protocol.md#action-cable-extended-protocol), which is supported by the [AnyCable JS client](https://github.com/anycable/anycable-client) out-of-the-box—no application level changes required.

  See [documentation](./anycable-go/reliable_streams.md) for details.

- **RPC over HTTP**.

  AnyCable now supports RPC over HTTP communication as an alternative to gRPC one. This allows you to embed AnyCable RPC part into your web server (e.g., Puma) without requiring a separate process or port. This is especially useful for Heroku deployments.

  See [documentation](./ruby/http_rpc.md) for details.

### Features

- **Redis X** broadcasting adapter.

  Redis X is a new broadcasting adapter that use Redis Streams instead of Publish/Subscribe to deliver broadcasting messages from your application to WebSocket servers. This is another step towards improved consistency: no message broadcasted from your application will be lost, even if WebSocket servers are temporarily unavailable. This is especially useful in combination with reliable streams.

  See [documentation](./ruby/broadcast_adapters.md#redis-x) for details.

### Changes

- Broadcasted messages are now delivered in the order they were received by the server.

  Previously, we used an executor pool internally to deliver broadcasted messages concurrently (to reduce the latency). That led to nonderterministic order of messages within a single stream delivered in a short period of time. Now, we preserve the order of messages within a stream—the delivered as they were accepted by the server.

  That means, with a single AnyCable-Go server, the following snippet will result in clients receiving the messages in the same order they were broadcasted:

  ```ruby
  10.times { ActionCable.server.broadcast "test", {text: "Count: #{_1}"} }

  # Client will receive the following messages:
  #
  #=> {"text"=>"Count: 0"}
  #=> {"text"=>"Count: 1"}
  #=> {"text"=>"Count: 2"}
  # ...
  #=> {"text"=>"Count: 9"}
  ```

  **NOTE:** In a clustered setup, the order of messages is not always guaranteed. For example, when using `http` or `redisx` adapter, each broadcasted message is handled by a single AnyCable-Go server independently, thus, there can be race conditions.

#### AnyCable-Go

- New disconnect modes and `--disable_disconnect` deprecation.

  AnyCable-Go becomes smarter with regards to performing Disconnect calls. In the default mode ("auto"), clients not relying on `#disconnect` / `#unsubscribed` callbacks do not trigger Disconnect RPC calls on connection close. Thus, if you use JWT identification and Hotwire signed streams with AnyCable-Go, you don't need to worry about the `--disable_disconnect` option to use AnyCable in the RPC-less mode.

  The previous `--disable_disconnect` behaviour can be achieved by setting `--disconnect_mode=never`.

## 1.3.0

### Features

#### Common

- Configuration presets (aka sensible defaults).

  AnyCable now automatically detects known platforms (Heroku, Fly) and tunes configuration accordingly. Right now, Fly.io support is the most comprehensive and allows you to automatically connect Ruby and AnyCable-Go apps to each other (by setting correct RPC and broadcasting URLs).

  See documentation for [AnyCable](./ruby/configuration.md#presets) and [AnyCable-Go](./anycable-go/configuration.md#presets).

#### AnyCable-Go
  <p class="pro-badge-header"></p>

- Added adaptive concurrency support.

  Users of AnyCable had to scale and balance resources on two sides: RPC and AnyCable-Go. Now AnyCable-Go can adjust its concurrency limit automatically to minimize errors (`ResourcesExhausted`) and maximize throughput (thus, reduce the backlog size) if possible. This means, you only have to scale the Rails application, and AnyCable-Go will balance itself alongside automatically.

  See [documentation](./anycable-go/rpc.md#adaptive-concurrency).

#### AnyCable-Go

- **Embedded NATS** support.

  Now it's possible to run a NATS server within an AnyCable-Go process, so you don't need to deploy a pub/sub engine yourself.

  See [documentation](./anycable-go/embedded_nats.md).

- StatsD and metric tags are now generally available (dowstreamed from PRO).

  See [documentation](./anycable-go/instrumentation.md#statsd).

- Added support for WebSocket endpoint paths.

  Now you can specify wildcards and placeholders in a WS endpoint for `anycable-go`:

  ```sh
  anycable-go --path="/{tenant}/cable
  ```

  This could be helpful to differentiate between clients or even different Action Cable Connection class instances at a Ruby side.

- Added `grpc_active_conn_num` metrics.

  Now you can monitor the actual number of gRPC connections established between a WebSocket server and RPC servers.

#### AnyCable Ruby

- Added experimental support for [grpc_kit](https://github.com/cookpad/grpc_kit) as a gRPC server implementation.

  Add `grpc_kit` to your Gemfile and specify `ANYCABLE_GRPC_IMPL=grpc_kit` env var to use it.

- Added mutual TLS support for connections to Redis.

#### AnyCable Rails

**NOTE:** Changes below are for v1.3.7 of the `anycable-rails` gem.

- Added Rails 7+ error reporting interface integration.

  If your error reporting software supports Rails built-in error reporting (e.g., Sentry does), you no longer need to configure `AnyCable.capture_exception { ... }` yourself.

### Changes

#### AnyCable Ruby

- A new configuration paramter, `rpc_max_connection_age`, has been added to replace the previous `rpc_server_args.max_connection_age_ms` (or `ANYCABLE_RPC_SERVER_ARGS__MAX_CONNECTION_AGE_MS`).

  It comes with the **default value of 300 (5 minutes)**.

  **NOTE:** The `rpc_max_connection_age` accepts seconds, not milliseconds.

---

For full list of changes see the corresponding change logs:

- [AnyCable Ruby gem](https://github.com/anycable/anycable/blob/v1.3.0/CHANGELOG.md)
- [AnyCable Rails gem](https://github.com/anycable/anycable-rails/blob/v1.3.0/CHANGELOG.md)
- [AnyCable Go](https://github.com/anycable/anycable-go/blob/v1.3.0/CHANGELOG.md)

## 1.2.0

### Features

- Add fastlane subscribing for Hotwire (Turbo Streams) and CableReady.

  Make it possible to terminate subscription requests at AnyCable Go without performing RPC calls.

  See [documentation](./anycable-go/signed_streams.md).

- Add JWT authentication/identification support.

  You can pass a properly structured token along the connection request to authorize the connection and set up _identifiers_ without peforming an RPC call.

  See [documentation](./anycable-go/jwt_identification.md).

## 1.1.0

**tl;dr** Housekeeping and internals refactoring, prepare for non-gRPC RPC, minor but useful additions.

See also [upgrade notes](./upgrade-notes/1_0_0_to_1_1_0.md).

### Features

- Added ability to embed AnyCable RPC into any Ruby process.

  When using `anycable-rails`, set `embedded: true` in the configuration to launch RPC along with `rails s` (only for Rails 6.1+).

  For any other Ruby process, drop the following snippet to launch an RPC server:

  ```ruby
  require "anycable/cli"
  AnyCable::CLI.embed!(*args) # args is a space-separated list of CLI args
  ```

- New metrics for `anycable-go`:
  - `server_msg_total` and `failed_server_msg_total`: the total number of messages sent (or failed to send) by server.
  - `data_sent_bytes_total` and `data_rcvd_bytes_total`: the total amount of bytes sent to (or received from) clients.

- New configuration parameters for `anycable-go`:
  - `--max-conn`: hard-limit the number of simultaneous server connections.
  - `--allowed_origins`: a comma-separated list of hostnames to check the Origin header against during the WebSocket Upgrade; supports wildcards, e.g., `--allowed_origins=*.evl.ms,www.evlms.io`.
  - `--ping_timestamp_precision`: define the precision for timestamps in ping messages (s, ms, ns).

### Changes

- Ruby 2.6+ is required for all Ruby gems (`anycable`, `anycable-rails`, `anycable-rack-server`).

- Rails 6.0+ is required for `anycable-rails`.

- Dropped deprecated AnyCable RPC v0.6 support.

- The `anycable` gem has been split into `anycable-core` and `anycable`.

  The first one contains an abstract RPC implementation and all the supporting tools (CLI, Protobuf), the second one adds the gRPC implementation.

- **BREAKING** Middlewares are no longer inherited from gRPC interceptors.

  That allowed us to have _real_ middlewares with ability to modify responses, intercept exceptions, etc.
  The API changed a bit:

  ```diff
  class SomeMiddleware < AnyCable::Middleware
  -  def call(request, rpc_call, rpc_handler)
  +  def call(rpc_method_name, request, metadata)
      yield
    end
  end
  ```

- Broadcasting messages is now happening concurrently.

  Now new broadcast messages are handled (and re-transmitted) concurrently by a pool of workers (Go routines).
  You can control the size of the pool via the `--hub_gopool_size` configuration parameter of the `anycable-go` server (defaults to 16).

---

For internal changes see the corresponding change logs:

- [AnyCable Ruby gem](https://github.com/anycable/anycable/blob/v1.1.0/CHANGELOG.md)
- [AnyCable Rails gem](https://github.com/anycable/anycable-rails/blob/v1.1.0/CHANGELOG.md)
- [AnyCable Go](https://github.com/anycable/anycable-go/blob/v1.1.0/CHANGELOG.md)
- [AnyCable Rack Server](https://github.com/anycable/anycable-rack-server/blob/v0.4.0/CHANGELOG.md)

---

## 1.0.0

**tl;dr** API stabilization, better Action Cable compatibility, [Stimulus Reflex][stimulus_reflex] compatibility, improved RPC communication, state persistence, HTTP broadcast adapter, Rails generators.

> Read more about the first major release of AnyCable in [Evil Martians chronicles](https://evilmartians.com/chronicles/anycable-1-0-four-years-of-real-time-web-with-ruby-and-go).

See also [upgrade notes](./upgrade-notes/0_6_0_to_1_0_0.md).

### Features

- Configure AnyCable for Rails apps via `rails g anycable:setup`.

  This interactive generator guides you through all the required steps to make AnyCable up and running for development and production.

- Channel state, or `state_attr_accessor`.

  Similarly to connection identifiers, it is now possible to store arbitrary\* data for _subscriptions_ (channel instances).
  Using `state_attr_accessor :a, :b` (from `anycable-rails`) you can define readers and writers to keep channel state between commands. When AnyCable is not activated (i.e., a different adapter is used for Action Cable), this method behaves like `attr_accessor`.

  \* GlobalID is used for serialization and deserialization of non-primitive objects.

- Rack middlewares support in Rails.

  You can use Rack middlewares to _enhance_ AnyCable `request` object.
  For that, add required middlewares to `AnyCable::Rails::Rack.middleware` using the same API as for Rails middleware.

  By default, only session store middleware is included, which allows you to access `request.session` without any hacks.

  A typical use-case is adding a Warden middleware for Devise-backed authentication.

  See [documentation](./rails/authentication.md).

- Underlying HTTP request data in now accessible in all RPC methods.

  That is, you can access `request` object in channels, too (e.g., headers/cookies/URL/etc).

- Remote disconnects.

  Disconnecting remote clients via `ActionCable.server.remote_connections.where(...).disconnect` is now supported.

- Rails session persistence.

  Now `request.session` could be persisted between RPC calls, and hence be used as a per-connection store. Originally added for [Stimulus Reflex][stimulus_reflex] compatibility.

  **NOTE:** This feature is optional and should be enabled explicitly in `anycable-rails` configuration.

  See [documentation](./rails/stimulus_reflex.md).

- HTTP broadcast adapter.

  Now you can experiment with AnyCable without having to install Redis.

  See [documentation](./ruby/broadcast_adapters.md#http-adapter).

  **NOTE:** Supported by `anycable` gem and `anycable-go`.

- Unsubscribing from a particular stream.

  See the corresponding [Rails PR](https://github.com/rails/rails/pull/37171).

- Redis Sentinel support.

  Both `anycable` gem and `anycable-go` now support using Redis with Sentinels.

  See [documentation](./ruby/broadcast_adapters.md#redis-sentinel-support).

- New metrics for `anycable-go`:
  - `mem_sys_bytes`: the total bytes of memory obtained from the OS
  - `rpc_retries_total`: the total number of retried RPC calls (higher number could indicate incorrect concurrency configuration)

- New configuration parameters for `anycable-go`:
  - `rpc_concurrency`: the limit on the number of concurrent RPC calls (read [documentation](./anycable-go/configuration.md#concurrency-settings)).
  - `enable_ws_compression`: enable WebSocket per-message compression (disabled by default).
  - `disconnect_timeout`: specify the timeout for graceful shutdown of the disconnect queue (read [documentation](./anycable-go/configuration.md#disconnect-events-settings))
  - `disable_disconnect`: disable calling disconnect/unsubscribe callbacks.

### Changes

- New RPC schema.

  Check out the annotated [new schema](./misc/rpc_proto.md).

- Ruby 2.5+ is required for all Ruby gems (`anycable`, `anycable-rails`, `anycable-rack-server`).

- Docker versioning changed from `vX.Y.Z` to `X.Y.Z` for `anycable-go`.

  Now you can specify only the part of the version, e.g. `anycable-go:1.0` instead of the full `anycable-go:v1.0.0`.

---

For internal changes see the corresponding change logs:

- [AnyCable Ruby gem](https://github.com/anycable/anycable/blob/v1.0.0/CHANGELOG.md)
- [AnyCable Rails gem](https://github.com/anycable/anycable-rails/blob/v1.0.0/CHANGELOG.md)
- [AnyCable Go](https://github.com/anycable/anycable-go/blob/v1.0.0/CHANGELOG.md)
- [AnyCable Rack Server](https://github.com/anycable/anycable-rack-server/blob/v0.2.0/CHANGELOG.md)

[stimulus_reflex]: https://github.com/hopsoft/stimulus_reflex
