# SNMP Check

# Overview

This check lets you collect SNMP metrics from your network devices.

# Installation

The SNMP check can be installed with your package manager, if the sd-agent repository is configured on your server, [instructions are available on our support site](https://support.serverdensity.com/hc/en-us/search?query=snmp). To install the SNMP check install the `sd-agent-snmp` package.

# Configuration

The SNMP check doesn't collect anything by default; you have to tell it specifically what to collect.

Here's an example `snmp.yaml`:

```
init_config:
   - mibs_folder: /path/to/your/additional/mibs

instances:
   - ip_address: localhost
     port: 161
     community_string: public
#    snmp_version: 1 # set to 1 if your devices use SNMP v1; no need to set otherwise, the default is 2
     timeout: 1      # in seconds; default is 1
     retries: 5
#    enforce_mib_constraints: false # set to false to NOT verify that returned values meet MIB constraints; default is true
     metrics:
       - MIB: UDP-MIB
         symbol: udpInDatagrams
       - OID: 1.3.6.1.2.1.6.5
         name: tcpPassiveOpens
       - MIB: IF-MIB
         table: ifTable
         symbols:
           - ifInOctets
           - ifOutOctets
         metric_tags:
           - tag: interface
             column: ifDescr
```

List each SNMP device as a distinct instance, and for each instance, list any SNMP counters and gauges you like in the `metrics` option. There are a few ways to specify what metrics to collect.

### MIB and symbol

```
    metrics:
      - MIB: UDP-MIB
        symbol: udpInDatagrams
```

### OID and name

```
    metrics:
      - OID: 1.3.6.1.2.1.6.5
        name: tcpActiveOpens # what to use in the metric name; can be anything
```

### MIB and table

```
    metrics:
      - MIB: IF-MIB
        table: ifTable
        symbols:
          - ifInOctets      # row whose value becomes metric value
        metric_tags:
          - tag: interface  # tag name
            column: ifDescr # the column name to get the tag value from, OR
            #index: 1       # the column index to get the tag value from
```

This lets you collect metrics on all rows in a table (`symbols`) and specify how to tag each metric (`metric_tags`).

### Use your own MIB

The SNMP check can collect MIB data that is formatted via [pysnmp](https://pypi.python.org/pypi/pysnmp). You can use the `build-pysnmp-mibs` script that ships with pysnmp to generate such data.

Put all your pysnmp MIBs into any directory and point the SNMP check to this directory: set `mibs_folder: <your_mibs_folder>` under the `init_config` section of `snmp.yaml`.

---

Restart the Agent to start sending SNMP metrics to Server Density.

# Validation

Run the Agent's `info` subcommand and look for `snmp` under the Checks section:

```
  Checks
  ======
    [...]

    snmp
    -------
      - instance #0 [OK]
      - Collected 26 metrics, 0 events & 1 service check

    [...]
```

# Compatibility

The snmp check is compatible with all major platforms.

# Metrics

The SNMP check doesn't generate any standard metrics, so [metadata.csv](metadata.csv) is empty.

The check submits collects and submits the metrics you specify under the `snmp.*` namespace.

