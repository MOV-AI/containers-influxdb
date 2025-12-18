# InfluxDB Container

Production-ready InfluxDB time-series database container optimized for IoT devices, monitoring systems, and high-volume data ingestion with automated retention policies and performance tuning.

## Features

- **InfluxDB 1.12.2** with Alpine Linux for minimal footprint
- **Automated Database Setup** with configurable retention policies
- **Performance Optimized** configuration for high-throughput workloads
- **Memory Efficient** with tuned cache and compaction settings
- **Health Monitoring** with built-in health checks
- **Multi-Database Support** with automatic initialization

## Quick Start

```bash
# Run with default settings
docker run -d -p 8086:8086 influxdb-container

# Run with custom databases and retention
docker run -d -p 8086:8086 \
  -e INFLUX_DATABASE="metrics logs telegraf" \
  -e INFLUX_DATABASE_RETENTION="30d" \
  influxdb-container

# Test connection
curl http://localhost:8086/ping

# Create a measurement
curl -i -XPOST 'http://localhost:8086/write?db=metrics' \
  --data-binary 'cpu_usage,host=server01 value=23.5'

# Query data
curl -G 'http://localhost:8086/query?db=metrics' \
  --data-urlencode 'q=SELECT * FROM cpu_usage'
```

### Build Image
```bash
docker build -t influxdb-container .
```

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 8086 | HTTP | InfluxDB HTTP API |

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `INFLUXDB_VERSION` | `1.12.2-alpine` | InfluxDB base image version |
| `INFLUX_DATABASE` | `telegraf logs metrics` | Databases to create on startup |
| `INFLUX_DATABASE_RETENTION` | `7d` | Default retention policy duration |
| `INFLUX_DATABASE_REPLICATION` | `1` | Replication factor for data |
| `INFLUX_DATABASE_SHARD_DURATION` | `1h` | Shard group duration |
| `INFLUXDB_ADMIN_USER` | - | Admin username (optional) |
| `INFLUXDB_ADMIN_PASSWORD` | - | Admin password (optional) |

### Memory Optimization Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `INFLUXD_REPORTING_DISABLED` | `true` | Disable usage reporting |
| `INFLUXD_STORAGE_CACHE_MAX_MEMORY_SIZE` | `419430400` | Max cache size (400 MiB) |
| `INFLUXD_STORAGE_CACHE_SNAPSHOT_WRITE_COLD_DURATION` | `120s` | Cache snapshot interval |
| `INFLUXD_STORAGE_COMPACT_FULL_WRITE_COLD_DURATION` | `1h0m0s` | Full compaction interval |
| `INFLUXD_STORAGE_COMPACT_THROUGHPUT_BURST` | `8388608` | Compaction burst (8 MiB) |
| `INFLUXD_STORAGE_MAX_CONCURRENT_COMPACTIONS` | `2` | Max concurrent compactions |

### Configuration Files

- **`files/influxdb.conf`**: Main InfluxDB configuration with performance optimizations
- **`files/retention_policy.sh`**: Automatic database creation and retention policy setup

### Key Settings (influxdb.conf)

- **Query logging**: Enabled for debugging
- **Internal monitoring**: Disabled for performance
- **HTTP pprof**: Enabled for troubleshooting
- **Retention service**: 30-minute check interval
- **Shard precreation**: 10-minute check, 30-minute advance

## Production Deployment

### Docker Compose Example

See `docker-compose.yml` for a complete setup including InfluxDB, Grafana, Chronograf, and Kapacitor with persistent storage and networking.

Make sure to login to GHCR with your GitHub credentials to pull the images:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### Security Considerations

**Important**: This configuration is optimized for development and testing. For production:

1. **Enable Authentication**: Set `INFLUXDB_ADMIN_USER` and `INFLUXDB_ADMIN_PASSWORD`
2. **Use HTTPS**: Configure TLS termination (reverse proxy recommended)
3. **Network Security**: Restrict access to port 8086
4. **Backup Strategy**: Implement regular database backups
5. **Monitor Resources**: Watch memory usage and disk space
6. **Update Regularly**: Keep InfluxDB version current

## Database Management

### Retention Policies

Databases are automatically created with configurable retention policies:

```bash
# Default: 7-day retention, 1-hour shards
INFLUX_DATABASE_RETENTION=7d
INFLUX_DATABASE_SHARD_DURATION=1h

# Long-term storage: 1-year retention, 1-day shards
INFLUX_DATABASE_RETENTION=365d
INFLUX_DATABASE_SHARD_DURATION=1d
```

### Multiple Databases

Specify multiple databases separated by spaces:

```bash
INFLUX_DATABASE="metrics logs events alerts telegraf"
```

Each database gets the same retention policy. For different retention periods, create databases manually after startup.

## Monitoring

### Health Check
```bash
# Container health
docker ps  # Check health status

# InfluxDB health
curl http://localhost:8086/ping
curl http://localhost:8086/health
```

### Performance Monitoring
```bash
# Database stats
curl 'http://localhost:8086/query' --data-urlencode 'q=SHOW STATS'

# Memory usage
curl 'http://localhost:8086/debug/pprof/heap'

# Active queries
curl 'http://localhost:8086/query' --data-urlencode 'q=SHOW QUERIES'
```

## Troubleshooting

### Common Issues

**High Memory Usage**: Adjust `INFLUXD_STORAGE_CACHE_MAX_MEMORY_SIZE` based on available RAM

**Slow Queries**: Enable query logging and check for inefficient queries

**Disk Space**: Monitor retention policies and shard group sizes

**Connection Issues**: Check if authentication is properly configured

### Logs
```bash
# Container logs
docker logs <container_id>

# InfluxDB query log
docker exec <container_id> tail -f /var/log/influxdb/influxdb.log
```

### Debug Mode
```bash
# Run with debug logging
docker run -e INFLUXD_LOGGING_LEVEL=debug influxdb-container
```

## Development

### Custom Configuration
```bash
# Build with custom InfluxDB version
docker build --build-arg INFLUXDB_VERSION=1.11.7-alpine -t influxdb-container .

# Mount custom config
docker run -v ./custom.conf:/etc/influxdb/influxdb.conf influxdb-container
```

### Testing
```bash
# Test database creation
docker run --rm \
  -e INFLUX_DATABASE="test_db" \
  -e INFLUX_DATABASE_RETENTION="1d" \
  influxdb-container

# Validate retention policy
curl 'http://localhost:8086/query' --data-urlencode 'q=SHOW RETENTION POLICIES ON test_db'
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

For issues and contributions, please visit: https://github.com/MOV-AI/containers-influxdb