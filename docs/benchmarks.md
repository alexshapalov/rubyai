<!-- markdownlint-disable no-inline-html -->

# Benchmarks

> The latest benchmark results are available at [the main repo](https://github.com/anycable/anycable/blob/master/benchmarks/2020-06-30.md).

**NOTE:** We run Action Cable with **eight** Puma workers. Using lower number of processes results in a much higher latency during broadcasting as well as connection timeout errors.

## Broadcasting RTT

Broadcasting round-trip time benchmark (based on [Hashrocket's bench](https://github.com/hashrocket/websocket-shootout)) measures how much time does it take for the server to re-transmit the message to all the connected clients–the less the time, the better the _real-time-ness_ of the server.

The results of this benchmark could be seen below.

<picture>
  <source srcset="/assets/images/rtt_bench_invert.png" media="(prefers-color-scheme: dark)">
  <img class="chart-container" alt="RTT" src="/assets/images/rtt_bench.png" width="80%">
</picture>

## Memory usage

Memory usage of AnyCable is significantly lower than of Action Cable.

That's achieved by moving memory-intensive operations into (storing connection states and subscriptions maps, serializing data into a standalone WebSocket server.

<picture>
  <source srcset="/assets/images/ram_bench_invert.png" media="(prefers-color-scheme: dark)">
  <img class="chart-container" alt="Memory usage" src="/assets/images/ram_bench.png" width="80%">
</picture>

## CPU usage

Below you can see the snapshot of CPU usage during the RTT benchmark.

<div class="chart-container">
  <div class="captioned-figure">
    <img src="/assets/images/anycable.gif" alt="AnyCable CPU">
    <label>AnyCable</label>
  </div>
  <div class="captioned-figure">
    <img src="/assets/images/actioncable.gif" alt="Action Cable CPU">
    <label>Action Cable</label>
  </div>
</div>
