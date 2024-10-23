# AnyCable

> A real-time server for Rails, Node.js, and Hotwire applications that runs on your servers and scales.

<picture>
  <source srcset="/assets/images/logo_invert.svg" media="(prefers-color-scheme: dark)">
  <img class="home-logo" align="right" height="150" width="129" title="AnyCable logo" src="/assets/images/logo.svg">
</picture>

AnyCable helps you build reliable and fast real-time features—notifications, chats, Hotwire frontends, and more. It works with any backend and provides seamless integrations for Ruby on Rails and serverless Node.js applications. Stay productive by writing clean, maintainable code in your language of choice with the assurance that your application scales efficiently.

Save up on infrastructure and PaaS bills without sacrificing productivity: a fast Go server handles the load, and your application deals with business logic. The [Pro version](./pro.md) offers even more benefits: delivery guarantees in cluster mode, fallback transport for private networks, GraphQL integration, added memory efficiency and more.

Make your real-time communication fast and [reliable](./anycable-go/reliable_streams.md) with AnyCable!

<!-- markdownlint-disable no-trailing-punctuation -->
## Getting started

- [Using AnyCable with Rails](rails/getting_started.md)

- [AnyCable as a real-time server for serverless JavaScript](guides/serverless.md)

- [Using AnyCable with Hotwire applications](guides/hotwire.md)

- [Using AnyCable with other Ruby frameworks](ruby/non_rails.md)

## Latest updates 🆕

- **2024-10-08**: [File-based configuration (`anycable.toml`)](./anycable-go/configuration.md)

- **2024-03-12**: [Standalone mode via signed streams](./anycable-go/signed_streams.md)

- **2023-11-08**: [AnyCable for serverlsess JavaScript applications](./guides/serverless.md)

- **2023-09-07**: [Server-sent events](./anycable-go/sse.md) suppport is added to AnyCable-Go 1.4.4+.

- **2023-08-04**: [Slow drain mode for disconnecting clients on shutdown <img class='pro-badge' src='/assets/pro.svg' alt='pro' />](./anycable-go/configuration.md#slow-drain-mode)

- **2023-07-05**: [Reliable streams](./anycable-go/reliable_streams.md)

## Resources

- [Official Website](https://anycable.io)

- [AnyCable Blog](https://anycable.io/blog)

- 🎥 [AnyCasts screencasts](https://www.youtube.com/playlist?list=PLAgBW0XUpyOVFnpoS6FKDszd8WEvXzg-A)

### Talks

- [The pitfalls of realtime-ification](https://noti.st/palkan/MeBUVe/the-pitfalls-of-realtime-ification), RailsConf 2022

- [High-speed cables for Ruby](https://noti.st/palkan/Y1bPpn/high-speed-cables-for-ruby), RubyConf 2018

- [One cable to rule them all](https://noti.st/palkan/ALKDiC/anycable-one-cable-to-rule-them-all), RubyKaigi 2018

## Acknowledgements

<br/>

<div style="display:flex;flex-direction: row;gap:20px">
<a href="https://evilmartians.com/">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://evilmartians.com/badges/sponsored-by-evil-martians_v2.0_for-dark-bg.svg">
  <img alt="Evil Martians logo" src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" width="236" height="54">
</picture>
</a>

<br/>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="/assets/fly-sponsored-landscape-dark.svg">
  <img alt="Sponsored by Fly.io" src="/assets/fly-sponsored-landscape-light.svg" height="97" width="259">
</picture>
</div>
