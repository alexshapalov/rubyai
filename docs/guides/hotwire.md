# Using AnyCable with Hotwire

AnyCable be used as a [Turbo Streams][] backend for **any application**, not only Ruby or Rails.

## Rails applications

Since [turbo-rails][] uses Action Cable under the hood, no additional configuration is required to use AnyCable with Hotwired Rails applications. See the [getting started guide](../rails/getting_started.md) for instructions.

We recommend using AnyCable in a _standalone mode_ (i.e., without running an [RPC server](../anycable-go/rpc.md)) for applications only using Action Cable for Turbo Streams. For that, you must accomplish the following steps:

- Generate AnyCable **application secret** for your application and store it in the credentials (`anycable.secret`) or the environment variable (`ANYCABLE_SECRET`).

- Enable JWT authentication by using the `action_cable_with_jwt_meta_tag(**identifiers)` helper instead of the `action_cable_meta_tag` (see [docs](../rails/authentication.md)).

- Configure Turbo to use your AnyCable application secret for signing streams:

  ```ruby
  # config/environments/production.rb
  config.turbo.signed_stream_verifier_key = "<your-secret>"
  ```

- Enable Turbo Streams support for AnyCable server:

  ```sh
  ANYCABLE_SECRET=your-secret \
  ANYCABLE_TURBO_STREAMS=true \
  anycable-go

  # or via cli args
  anycable-go --secret=your-secret --turbo_streams
  ```

That's it! Now you Turbo Stream connections are served solely by AnyCable server.

## Other frameworks and languages

Hotwire is not limited to Ruby on Rails. You can use Turbo with any backend. Live updates via Turbo Streams, however, require a _connection_ to receive the updates. This is where AnyCable comes into play.

You can use AnyCable as a real-time server for Turbo Streams as follows:

- Use [JWT authentication](../anycable-go/jwt_identification.md) to authenticate connections (or run your AnyCable server with authentication disabled via the `--noauth` option)

- Enable [Turbo signed streams](../anycable-go/signed_streams.md#hotwire-and-cableready-support) support.

- Configure your backend to broadcast Turbo Streams updates via AnyCable (see [broadcasting documentation](../anycable-go/broadcasting.md)).

With this setup, you can use `@hotwired/turbo-rails` or [@anycable/turbo-stream][] JavaScript libraries in your application without any modification.

## Turbo Streams over Server-Sent Events

AnyCable supports [Server-Sent Events](../anycable-go/sse.md) (SSE) as a transport protocol. This means that you can use Turbo Streams with AnyCable without WebSockets and Action Cable (or AnyCable) client libraries—just with the help of the browser native `EventSource` API.

To create a Turbo Stream subscription over SSE, you must provide an URL to AnyCable SSE endpoint with the signed stream name as a query parameter when adding a `<turbo-stream-source>` element on the page:

```html
<turbo-stream-source src="https://cable.example.com/events?turbo_signed_stream_name=<signed-name>" />
```

That's it! Now you can broadcast Turbo Stream updates from your backend. Moreover, AnyCable supports the `Last-Event-ID` feature of EventSource, which means your **connection is reliable** and you won't miss any updates even if network is unstable. Don't forget to enable the [reliable streams](../anycable-go/reliable_streams.md) feature.

[Turbo Streams]: https://turbo.hotwired.dev/handbook/streams
[turbo-rails]: https://github.com/hotwired/turbo-rails
[@anycable/turbo-stream]: https://github.com/anycable/anycable-client/tree/master/packages/turbo-stream
