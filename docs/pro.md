# AnyCable-Go

<p class="pro-badge-header"></p>

AnyCable-Go Pro aims to bring AnyCable to the next level of efficient resources usage and developer ~~experience~~ happiness.

> Read also <a rel="noopener" href="https://evilmartians.com/chronicles/anycable-goes-pro-fast-websockets-for-ruby-at-scale" target="_blank">AnyCable Goes Pro: Fast WebSockets for Ruby, at scale</a>.

## Memory usage

Pro version uses a different memory model under the hood, which gives you yet another **30-50% RAM usage reduction**.

Here is the results of running [websocket-bench][] `broadcast` and `connect` benchmarks and measuring RAM used:

| version | broadcast 5k | connect 10k |  connect 15k |
|---|----|---|---|
| 1.3.0-pro               |  142MB | 280MB | 351MB |
| 1.3.0-pro (w/o poll)\*  |  207MB | 343MB | 480MB |
| 1.3.0                   |  217MB | 430MB | 613MB |

\* AnyCable-Go Pro uses epoll/kqueue to react on incoming messages by default.
In most cases, that should work the same way as with non-Pro version; however, if you have a really high rate of
incoming messages, you might want to fallback to the _actor-per-connection_ model (you can do this by specifying `--netpoll_enabled=false`).

**NOTE:** Currently, using net polling is not compatible with WebSocket per-message compression (it's disabled even if you enabled it explicitly).

## More features

- [Adaptive RPC concurrency](anycable-go/rpc.md#adaptive-concurrency)
- [Multi-node streams history](anycable-go/reliable_streams.md#redis)
- [Slow drain mode for disconnecting clients on shutdown](anycable-go/configuration.md#slow-drain-mode)
- [Binary messaging formats](anycable-go/binary_formats.md)
- [Apollo GraphQL protocol support](anycable-go/apollo.md)
- [Long polling support](anycable-go/long_polling.md)
- [OCCP support](anycable-go/occp.md)

## Installation

Read our [installation guide](pro/install.md).

[websocket-bench]: https://github.com/anycable/websocket-bench
