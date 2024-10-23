<!-- markdownlint-disable no-inline-html -->
# Getting started

AnyCable is a language-agnostic server for web applications that brings performance and reliability to your real-time features. It follows Rails Action Cable conventions and uses [Action Cable protocol](misc/action_cable_protocol.md) as a primary communication protocol (while supporting others as well). AnyCable is a multi-transport server supporting WebSockets, [Server-Sent Events](/anycable-go/sse.md) and [long-polling](/anycable-go/long_polling.md).

<div class="chart-container" data-view-transition="chart">
  <img class="is-light" src="/assets/images/anycable.svg" alt="AnyCable diagram" width="40%">
  <img class="is-dark" src="/assets/images/anycable_dark.svg" alt="AnyCable diagram" width="40%">
</div>

The primary goal of AnyCable is to make it possible to write a high-performant real-time application keeping business-logic in your backend application (whether it's Ruby on Rails or serverless JavaScript or whatever).

AnyCable could be used with the existing Action Cable clients (such as [Rails JavaScript client](https://www.npmjs.com/package/actioncable) or [Action Cable CLI](https://github.com/palkan/acli)) without any change. However, for web development we recommend using [AnyCable JS/TS client](https://github.com/anycable/anycable-client), which provides better compatibility with AnyCable-specific features.

You can use AnyCable with:

- Action Cable (Rails) applications (see [Using with Rails](rails/getting_started.md))
- Hotwire applications (see [Using with Hotwire](guides/hotwire.md))
- JavaScript applications (see [Using with JavaScript](/guides/serverless.md))
- [Lite Cable](https://github.com/palkan/litecable) for  _plain_ Ruby projects (see [Using with Ruby](ruby/non_rails.md))
