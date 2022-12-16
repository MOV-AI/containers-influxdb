# containers-influxdb

Configuration ENV vars:

    INFLUXDB_INIT_PORT
    INFLUX_DATABASE
    INFLUX_DATABASE_RETENTION
    INFLUX_DATABASE_REPLICATION

Extra memory configuration can be done by setting those ENV vars:

    INFLUXD_REPORTING_DISABLED="true"
    INFLUXD_STORAGE_CACHE_MAX_MEMORY_SIZE=419430400 (400 MiB)
    INFLUXD_STORAGE_CACHE_SNAPSHOT_WRITE_COLD_DURATION="120s"
    INFLUXD_STORAGE_COMPACT_FULL_WRITE_COLD_DURATION="1h0m0s"
    INFLUXD_STORAGE_COMPACT_THROUGHPUT_BURST=8388608 (8 MiB)
    INFLUXD_STORAGE_MAX_CONCURRENT_COMPACTIONS=2
    INFLUXD_STORAGE_SERIES_FILE_MAX_CONCURRENT_SNAPSHOT_COMPACTIONS=2