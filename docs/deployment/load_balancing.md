# Load balancing

## RPC load balancing

You can use load balancers to scale your application and/or perform zero-disconnect deployments (by doing a rolling update of RPC servers without restarting WebSocket servers).

### Using Linkerd

Check out this blog post: [Scaling Rails web sockets in Kubernetes with AnyCable](https://blog.anycable.io/p/scaling-rails-websockets-in-kubernetes).

### Using Envoy

[Envoy](https://envoyproxy.io) is a modern proxy server which supports HTTP2 and gRPC.

See [the example configuration](https://github.com/anycable/anycable-go/tree/master/etc/envoy) in the `anycable-go` repo.

### Using NGINX

You can use NGINX [gRPC module](http://nginx.org/en/docs/http/ngx_http_grpc_module.html) to distribute traffic across multiple RPC servers.

The minimalist configuration looks like this (credits goes to [avlazarov](https://gist.github.com/avlazarov/9503c23d81c75f760e14b30e38847356#file-grpc-confe)):

```conf
upstream grpcservers {
    server 0.0.0.0:50051;
    server 0.0.0.0:50052;
}

server {
    listen 50050 http2;
    server_name localhost;

    access_log /var/log/nginx/grpc_log.json;
    error_log /var/log/nginx/grpc_error_log.json debug;

    location / {
        grpc_pass grpc://grpcservers;
    }
}
```

### Client-side load balancing

gRPC clients (more precisely, [grpc-go](https://github.com/grpc/grpc-go) used by `anycable-go`) provide client-level load balancing via DNS resolving. If the provided hostname resolves to multiple A records, a client connect to all of them and use round-robin strategy to distribute the requests.

To activate this mechanism, you MUST provide use the following schema to build an URI: `dns://[authority]/host[:port]`.

For example, when using Docker, you can rely on its internal DNS server and omit the `authority` part altogether: `ANYCABLE_RPC_HOST=dns:///rpc:50051` (**three** slashes!). See the [docs](https://github.com/grpc/grpc/blob/master/doc/naming.md).

Since gRPC clients performs the DNS resolution only during the connection initialization, newly added servers (in case of auto-scaling) are not picked up. To resolve this issue, you can configure a max connection lifetime at the server side, so, connections are recreated periodically (that also triggers re-resolution).

You can control gRPC connection lifetimes via the `rpc_max_connection_age` configuration option for AnyCable RPC server (could be also configured via the `ANYCABLE_RPC_MAX_CONNECTION_AGE` env variable). It's set to 300 (seconds, thus, 5 minutes) by default, so you're likely don't want to change it.

You can also monitor the current number of gRPC connections by looking at the AnyCable-Go's `grpc_active_conn_num` metrics value.

## WebSocket load balancing

There is nothing specific in load balancing AnyCable WebSocket server comparing to other WebSocket applications. See, for example, [NGINX documentation](https://www.nginx.com/blog/websocket-nginx/).

**NOTE:** We recommend to use a _least connected_ strategy for WebSockets to have more uniform clients distribution (see, for example, [NGINX](http://nginx.org/en/docs/http/load_balancing.html#nginx_load_balancing_with_least_connected)).

<!-- TODO: add demos -->
