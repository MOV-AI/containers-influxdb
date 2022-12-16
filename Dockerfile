ARG DOCKER_REGISTRY="registry.cloud.mov.ai"
ARG INFLUXDB_VERSION="1.8.10-alpine"
FROM influxdb:${INFLUXDB_VERSION}

# Labels
LABEL description="MOV.AI InfluxDB Base Image"
LABEL maintainer="devops@mov.ai"
LABEL movai="influxdb"

# Files
COPY files/influxdb.conf /etc/influxdb/influxdb.conf
# Copy entrypoint script
COPY files/retention_policy.sh /docker-entrypoint-initdb.d/
# Entrypoint
