# Redis Integration

# Overview

Whether you use Redis as a database, cache, or message queue, this integration helps you track problems with your Redis servers and the parts of your infrastructure that they serve. The Server Density Agent's Redis check collects a wealth of metrics related to performance, memory usage, blocked clients, slave connections, disk persistence, expired and evicted keys, and many more.

# Installation

The Redis check can be installed with your package manager, if the sd-agent repository is configured on your server, [instructions are available on our support site](https://support.serverdensity.com/hc/en-us/search?query=redis). To install the Redis check install the `sd-agent-redis` package.

# Configuration

Create a `redisdb.yaml` in the Server Density Agent's `conf.d` directory:

```
init_config:

instances:
  - host: localhost
    port: 6379 # or wherever your redis listens
#   unix_socket_path: /var/run/redis/redis.sock # if your redis uses a socket instead of TCP
#   password: myredispassword                   # if your redis requires auth
```

See [this sample redisdb.yaml](https://github.com/serverdensity/sd-agent-core-plugins/blob/master/redisdb/conf.yaml.example) for all available configuration options.

Restart the Agent to begin sending Redis metrics to Server Density.

# Validation

Run the Agent's `info` subcommand and look for `redis` under the Checks section:

```
  Checks
  ======
    [...]

    redisdb
    -------
      - instance #0 [OK]
      - Collected 26 metrics, 0 events & 1 service check

    [...]
```

# Troubleshooting

## Agent cannot connect
```
    redisdb
    -------
      - instance #0 [ERROR]: 'Error 111 connecting to localhost:6379. Connection refused.'
      - Collected 0 metrics, 0 events & 1 service chec
```

Check that the connection info in `redisdb.yaml` is correct.

## Agent cannot authenticate
```
    redisdb
    -------
      - instance #0 [ERROR]: 'NOAUTH Authentication required.'
      - Collected 0 metrics, 0 events & 1 service check
```

Configure a `password` in `redisdb.yaml`.

# Compatibility

The redis check is compatible with all major platforms.

# Metrics

See [metadata.csv](metadata.csv) for a list of metrics provided by this integration.
