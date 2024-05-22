ARG DOCKER_REGISTRY="registry.cloud.mov.ai"
ARG INFLUXDB_VERSION="2.7-alpine"
FROM influxdb:${INFLUXDB_VERSION}

# Labels
LABEL description="MOV.AI InfluxDB Base Image"
LABEL maintainer="devops@mov.ai"
LABEL movai="influxdb"

# see https://docs.influxdata.com/influxdb/v2/install/upgrade/v1-to-v2/docker/
# v2 needs upgrading the database and the configuration
ENV DOCKER_INFLUXDB_INIT_MODE="upgrade"
# v2 needs authentication parameters
ENV DOCKER_INFLUXDB_INIT_USERNAME="admin" \
  DOCKER_INFLUXDB_INIT_PASSWORD="admin@123" \
  DOCKER_INFLUXDB_INIT_ORG="movai" \
  DOCKER_INFLUXDB_INIT_BUCKET="test"
# v2 needs the token to be set
# v2 might need new volumes to be mounted


# Files
COPY files/influxdb.conf /etc/influxdb/influxdb.conf
# Copy entrypoint script
COPY files/retention_policy.sh /docker-entrypoint-initdb.d/
# Entrypoint
