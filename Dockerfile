ARG INFLUXDB_VERSION=1.12.2-alpine

FROM influxdb:${INFLUXDB_VERSION}

# Labels
LABEL description="MOV.AI InfluxDB Container with optimized configuration"
LABEL maintainer="https://github.com/MOV-AI/containers-influxdb"
LABEL org.opencontainers.image.source="https://github.com/MOV-AI/containers-influxdb"
LABEL org.opencontainers.image.description="InfluxDB time-series database optimized for IoT and monitoring workloads"
LABEL movai="influxdb"

# Environment variables
ENV ENV="release" \
    INFLUX_DATABASE="telegraf logs metrics" \
    INFLUX_DATABASE_RETENTION="7d" \
    INFLUX_DATABASE_REPLICATION="1"

# Copy configuration files
COPY files/influxdb.conf /etc/influxdb/influxdb.conf
COPY files/retention_policy.sh /docker-entrypoint-initdb.d/

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD echo > /dev/tcp/localhost/8086 || exit 1
