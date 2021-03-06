# Overview

The Server Density Agent can collect many metrics from MySQL databases, including:

* Query throughput
* Query performance (average query run time, slow queries, etc)
* Connections (currently open connections, aborted connections, errors, etc)
* InnoDB (buffer pool metrics, etc)

And many more. You can also invent your own metrics using custom SQL queries.

# Installation

The MySQL check can be installed with your package manager, if the sd-agent repository is configured on your server, [instructions are available on our support site](https://support.serverdensity.com/hc/en-us/search?query=mysql). To install the MySQL check install the `sd-agent-mysql` package.

# Configuration

### Prepare MySQL

On each MySQL server, create a database user for the Server Density Agent:

```
mysql> CREATE USER 'serverdensity'@'localhost' IDENTIFIED BY '<YOUR_CHOSEN_PASSWORD>';
Query OK, 0 rows affected (0.00 sec)
```

The Agent needs a few privileges to collect metrics. Grant its user ONLY the following privileges:

```
mysql> GRANT REPLICATION CLIENT ON *.* TO 'serverdensity'@'localhost' WITH MAX_USER_CONNECTIONS 5;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> GRANT PROCESS ON *.* TO 'serverdensity'@'localhost';
Query OK, 0 rows affected (0.00 sec)
```

If the MySQL server has the `performance_schema` database enabled and you want to collect metrics from it, the Agent's user needs one more `GRANT`. Check that `performance_schema` exists and run the `GRANT` if so:

```
mysql> show databases like 'performance_schema';
+-------------------------------+
| Database (performance_schema) |
+-------------------------------+
| performance_schema            |
+-------------------------------+
1 row in set (0.00 sec)

mysql> GRANT SELECT ON performance_schema.* TO 'serverdensity'@'localhost';
Query OK, 0 rows affected (0.00 sec)
```

### Connect the Agent

Create a basic `mysql.yaml` in the Agent's `conf.d` directory to connect it to the MySQL server:

```
init_config:

instances:
  - server: localhost
    user: serverdensity
    pass: <YOUR_CHOSEN_PASSWORD> # from the CREATE USER step earlier
    port: <YOUR_MYSQL_PORT> # e.g. 3306
    options:
        replication: 0
        galera_cluster: 1
        extra_status_metrics: true
        extra_innodb_metrics: true
        extra_performance_metrics: true
        schema_size_metrics: false
        disable_innodb_metrics: false
```

If you found above that MySQL doesn't have `performance_schema` enabled, do not set `extra_performance_metrics` to `true`.

See our [sample mysql.yaml](https://github.com/serverdensity/sd-agent-core-plugins/blob/master/mysql/conf.yaml.example) for all available configuration options, including those for custom metrics.

Restart the Agent to start sending MySQL metrics to Server Density.

# Validation

Run the Agent's `info` subcommand and look for `mysql` under the Checks section:

```
  Checks
  ======

    [...]

    mysql
    -----
      - instance #0 [OK]
      - Collected 168 metrics, 0 events & 1 service check

    [...]
```

If the status is not OK, see the Troubleshooting section.

# Troubleshooting

You may observe one of these common problems in the output of the Server Density Agent's `info` subcommand.

### Agent cannot authenticate
```
    mysql
    -----
      - instance #0 [ERROR]: '(1045, u"Access denied for user \'serverdensity\'@\'localhost\' (using password: YES)")'
      - Collected 0 metrics, 0 events & 1 service check
```

Either the `'serverdensity'@'localhost'` user doesn't exist or the Agent is not configured with correct credentials. Review the Configuration section to add a user, and review the Agent's `mysql.yaml`.

### Database user lacks privileges
```
    mysql
    -----
      - instance #0 [WARNING]
          Warning: Privilege error or engine unavailable accessing the INNODB status                          tables (must grant PROCESS): (1227, u'Access denied; you need (at least one of) the PROCESS privilege(s) for this operation')
      - Collected 21 metrics, 0 events & 1 service check
```

The Agent can authenticate, but it lacks privileges for one or more metrics it wants to collect. In this case, it lacks the PROCESS privilege:

```
mysql> select user,host,process_priv from mysql.user where user='serverdensity';
+---------------+-----------+--------------+
| user          | host      | process_priv |
+---------------+-----------+--------------+
| serverdebsity | localhost | N            |
+---------------+-----------+--------------+
1 row in set (0.00 sec)
```

Review the Configuration section and grant the serverdensity user all necessary privileges. Do NOT grant all privileges on all databases to this user.

# Compatibility

The MySQL integration is supported on versions x.x+

# Metrics

See [metadata.csv](metadata.csv) for a list of metrics provided by this check.

The check does not collect all metrics by default. Set the following boolean configuration options to `true` to enable its metrics:

|`extra_status_metrics`|
|----------|--------|
| mysql.binlog.cache_disk_use | GAUGE |
| mysql.binlog.cache_use | GAUGE |
| mysql.performance.handler_commit | RATE |
| mysql.performance.handler_delete | RATE |
| mysql.performance.handler_prepare | RATE |
| mysql.performance.handler_read_first | RATE |
| mysql.performance.handler_read_key | RATE |
| mysql.performance.handler_read_next | RATE |
| mysql.performance.handler_read_prev | RATE |
| mysql.performance.handler_read_rnd | RATE |
| mysql.performance.handler_read_rnd_next | RATE |
| mysql.performance.handler_rollback | RATE |
| mysql.performance.handler_update | RATE |
| mysql.performance.handler_write | RATE |
| mysql.performance.opened_tables | RATE |
| mysql.performance.qcache_total_blocks | GAUGE |
| mysql.performance.qcache_free_blocks | GAUGE |
| mysql.performance.qcache_free_memory | GAUGE |
| mysql.performance.qcache_not_cached | RATE |
| mysql.performance.qcache_queries_in_cache | GAUGE |
| mysql.performance.select_full_join | RATE |
| mysql.performance.select_full_range_join | RATE |
| mysql.performance.select_range | RATE |
| mysql.performance.select_range_check | RATE |
| mysql.performance.select_scan | RATE |
| mysql.performance.sort_merge_passes | RATE |
| mysql.performance.sort_range | RATE |
| mysql.performance.sort_rows | RATE |
| mysql.performance.sort_scan | RATE |
| mysql.performance.table_locks_immediate | GAUGE |
| mysql.performance.table_locks_immediate.rate | RATE |
| mysql.performance.threads_cached | GAUGE |
| mysql.performance.threads_created | MONOTONIC |

|`extra_innodb_metrics`|
|----------|--------|
| mysql.innodb.active_transactions | GAUGE |
| mysql.innodb.buffer_pool_data | GAUGE |
| mysql.innodb.buffer_pool_pages_data | GAUGE |
| mysql.innodb.buffer_pool_pages_dirty | GAUGE |
| mysql.innodb.buffer_pool_pages_flushed | RATE |
| mysql.innodb.buffer_pool_pages_free | GAUGE |
| mysql.innodb.buffer_pool_pages_total | GAUGE |
| mysql.innodb.buffer_pool_read_ahead | RATE |
| mysql.innodb.buffer_pool_read_ahead_evicted | RATE |
| mysql.innodb.buffer_pool_read_ahead_rnd | GAUGE |
| mysql.innodb.buffer_pool_wait_free | MONOTONIC |
| mysql.innodb.buffer_pool_write_requests | RATE |
| mysql.innodb.checkpoint_age | GAUGE |
| mysql.innodb.current_transactions | GAUGE |
| mysql.innodb.data_fsyncs | RATE |
| mysql.innodb.data_pending_fsyncs | GAUGE |
| mysql.innodb.data_pending_reads | GAUGE |
| mysql.innodb.data_pending_writes | GAUGE |
| mysql.innodb.data_read | RATE |
| mysql.innodb.data_written | RATE |
| mysql.innodb.dblwr_pages_written | RATE |
| mysql.innodb.dblwr_writes | RATE |
| mysql.innodb.hash_index_cells_total | GAUGE |
| mysql.innodb.hash_index_cells_used | GAUGE |
| mysql.innodb.history_list_length | GAUGE |
| mysql.innodb.ibuf_free_list | GAUGE |
| mysql.innodb.ibuf_merged | RATE |
| mysql.innodb.ibuf_merged_delete_marks | RATE |
| mysql.innodb.ibuf_merged_deletes | RATE |
| mysql.innodb.ibuf_merged_inserts | RATE |
| mysql.innodb.ibuf_merges | RATE |
| mysql.innodb.ibuf_segment_size | GAUGE |
| mysql.innodb.ibuf_size | GAUGE |
| mysql.innodb.lock_structs | RATE |
| mysql.innodb.locked_tables | GAUGE |
| mysql.innodb.locked_transactions | GAUGE |
| mysql.innodb.log_waits | RATE |
| mysql.innodb.log_write_requests | RATE |
| mysql.innodb.log_writes | RATE |
| mysql.innodb.lsn_current | RATE |
| mysql.innodb.lsn_flushed | RATE |
| mysql.innodb.lsn_last_checkpoint | RATE |
| mysql.innodb.mem_adaptive_hash | GAUGE |
| mysql.innodb.mem_additional_pool | GAUGE |
| mysql.innodb.mem_dictionary | GAUGE |
| mysql.innodb.mem_file_system | GAUGE |
| mysql.innodb.mem_lock_system | GAUGE |
| mysql.innodb.mem_page_hash | GAUGE |
| mysql.innodb.mem_recovery_system | GAUGE |
| mysql.innodb.mem_thread_hash | GAUGE |
| mysql.innodb.mem_total | GAUGE |
| mysql.innodb.os_file_fsyncs | RATE |
| mysql.innodb.os_file_reads | RATE |
| mysql.innodb.os_file_writes | RATE |
| mysql.innodb.os_log_pending_fsyncs | GAUGE |
| mysql.innodb.os_log_pending_writes | GAUGE |
| mysql.innodb.os_log_written | RATE |
| mysql.innodb.pages_created | RATE |
| mysql.innodb.pages_read | RATE |
| mysql.innodb.pages_written | RATE |
| mysql.innodb.pending_aio_log_ios | GAUGE |
| mysql.innodb.pending_aio_sync_ios | GAUGE |
| mysql.innodb.pending_buffer_pool_flushes | GAUGE |
| mysql.innodb.pending_checkpoint_writes | GAUGE |
| mysql.innodb.pending_ibuf_aio_reads | GAUGE |
| mysql.innodb.pending_log_flushes | GAUGE |
| mysql.innodb.pending_log_writes | GAUGE |
| mysql.innodb.pending_normal_aio_reads | GAUGE |
| mysql.innodb.pending_normal_aio_writes | GAUGE |
| mysql.innodb.queries_inside | GAUGE |
| mysql.innodb.queries_queued | GAUGE |
| mysql.innodb.read_views | GAUGE |
| mysql.innodb.rows_deleted | RATE |
| mysql.innodb.rows_inserted | RATE |
| mysql.innodb.rows_read | RATE |
| mysql.innodb.rows_updated | RATE |
| mysql.innodb.s_lock_os_waits | RATE |
| mysql.innodb.s_lock_spin_rounds | RATE |
| mysql.innodb.s_lock_spin_waits | RATE |
| mysql.innodb.semaphore_wait_time | GAUGE |
| mysql.innodb.semaphore_waits | GAUGE |
| mysql.innodb.tables_in_use | GAUGE |
| mysql.innodb.x_lock_os_waits | RATE |
| mysql.innodb.x_lock_spin_rounds | RATE |
| mysql.innodb.x_lock_spin_waits | RATE |

|`extra_performance_metrics` adds the following metrics:|
|----------|--------|
| mysql.performance.query_run_time.avg | GAUGE |
| mysql.performance.digest_95th_percentile.avg_us | GAUGE |

|`schema_size_metrics` adds the following metric:|
|----------|--------|
| mysql.info.schema.size | GAUGE |

