# Systemd configurations

If you prefer to run AnyCable without containerization, we recommend running it as a system service for better manageability.

On most modern Linux distributions this can be done by declaring a [systemd](https://www.freedesktop.org/wiki/Software/systemd/) service like this:

1. Edit as needed and save the following script to `/etc/systemd/system/anycable-<rpc|go>.service`.
1. Reload systemd configuration via `sudo systemctl daemon-reload`.
1. Start the service: `sudo systemctl start anycable-go anycable-rpc`.

## AnyCable RPC

```ini
# /etc/systemd/system/anycable-rpc.service

[Unit]
Description=AnyCable gRPC Server
After=syslog.target network.target

[Service]
Type=simple
Environment=RAILS_ENV=production
WorkingDirectory=/path-to-your-project/current/
ExecStart=bundle exec anycable
# or if you're using rbenv/rvm
# ExecStart=/bin/bash -lc 'bundle exec anycable'
ExecStop=/bin/kill -TERM $MAINPID

# Set user/group
# User=www
# Group=www
# UMask=0002

# Set memory limits
# MemoryHigh=2G
# MemoryMax=3G
# MemoryAccounting=true

Restart=on-failure


# Configure WebSocket server using env vars (see Configuration guide)
# Environment=ANYCABLE_REDIS_URL=redis://localhost:6379/5
# Environment=ANYCABLE_REDIS_CHANNEL=__anycable__

[Install]
WantedBy=multi-user.target
```

## AnyCable-Go

```ini
[Unit]
Description=AnyCable Go WebSocket Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/anycable-go
ExecStop=/bin/kill -TERM $MAINPID

# User=xxx
# Group=xxx
UMask=0002
LimitNOFILE=16384 # increase open files limit (see OS Tuning guide)

Restart=on-failure

# Configure WebSocket server using env vars
# Environment=ANYCABLE_HOST=localhost
# Environment=ANYCABLE_PORT=8080
# Environment=ANYCABLE_PATH=/cable
# Environment=ANYCABLE_REDIS_URL=redis://localhost:6379/5
# Environment=ANYCABLE_REDIS_CHANNEL=__anycable__
# Environment=ANYCABLE_RPC_HOST=localhost:50051
# Environment=ANYCABLE_METRICS_HTTP=/metrics

[Install]
WantedBy=multi-user.target
```

## Resources

- [Deploy AnyCable with Capistrano and systemd](https://jetrockets.com/blog/deploy-anycable-with-capistrano-and-systemd) by [JetRockets](https://jetrockets.com).
