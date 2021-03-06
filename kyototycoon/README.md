# Kyototycoon Integration

# Overview

The Agent's Kyototycoon check tracks get, set, and delete operations, and lets you monitor replication lag.

# Installation

The Kyototycoon check can be installed with your package manager, if the sd-agent repository is configured on your server, [instructions are available on our support site](https://support.serverdensity.com/hc/en-us/search?query=kyototycoon). To install the Kyototycoon check install the `sd-agent-kyototycoon` package.

# Configuration

Create a file `kyototycoon.yaml` in the Agent's `conf.d` directory:

```
init_config:

instances:
#  Each instance needs a report URL.
#  name, and optionally tags keys. The report URL should
#  be a URL to the Kyoto Tycoon "report" RPC endpoint.
#
#  Complete example:
#
- report_url: http://localhost:1978/rpc/report
#   name: my_kyoto_instance
#   tags:
#     foo: bar
#     baz: bat
```

# Validation

Run the Agent's `info` subcommand and look for `kyototycoon` under the Checks section:

```
  Checks
  ======
    [...]

    kyototycoon
    -------
      - instance #0 [OK]
      - Collected 26 metrics, 0 events & 1 service check

    [...]
```

# Compatibility

The kyototycoon check is compatible with all major platforms.

# Metrics

See [metadata.csv](metadata.csv) for a list of metrics provided by this check.

