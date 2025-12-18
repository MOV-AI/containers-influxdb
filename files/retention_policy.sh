#!/bin/bash
set -e

echo "=== InfluxDB Database Initialization ==="

echo "Configuring production retention policies ..."
INFLUXDB_INIT_PORT="${INFLUXDB_INIT_PORT:-8086}"
INFLUX_DATABASES="${INFLUX_DATABASE:-telegraf logs metrics}"
INFLUX_DATABASE_RETENTION="${INFLUX_DATABASE_RETENTION:-7d}"
INFLUX_DATABASE_REPLICATION="${INFLUX_DATABASE_REPLICATION:-1}"
INFLUX_DATABASE_SHARD_DURATION="${INFLUX_DATABASE_SHARD_DURATION:-1h}"
INTERNAL_INFLUX_DATABASE="_internal"
INTERNAL_INFLUX_DATABASE_RETENTION="${INTERNAL_INFLUX_DATABASE_RETENTION:-1d}"
INTERNAL_INFLUX_DATABASE_REPLICATION="${INTERNAL_INFLUX_DATABASE_REPLICATION:-1}"
INTERNAL_INFLUX_DATABASE_SHARD_DURATION="${INTERNAL_INFLUX_DATABASE_SHARD_DURATION:-1h}"

# Wait for InfluxDB to be ready
echo "Waiting for InfluxDB to be ready..."
INFLUX_CMD="influx -host 127.0.0.1 -port $INFLUXDB_INIT_PORT -execute"
until $INFLUX_CMD "SHOW DATABASES" >/dev/null 2>&1; do
    echo "InfluxDB is not ready yet. Retrying in 1s..."
    sleep 1
done

# Build InfluxDB command based on authentication settings
if [ -n "${INFLUXDB_ADMIN_USER}" ] && [ -n "${INFLUXDB_ADMIN_PASSWORD}" ]; then
    echo "Using admin authentication"
    INFLUX_CMD="influx -host 127.0.0.1 -port $INFLUXDB_INIT_PORT -username ${INFLUXDB_ADMIN_USER} -password ${INFLUXDB_ADMIN_PASSWORD} -execute"
else
    echo "Using anonymous access (not recommended for production)"
    INFLUX_CMD="influx -host 127.0.0.1 -port $INFLUXDB_INIT_PORT -execute"
fi

# Function to execute InfluxDB commands with error handling
execute_influx_cmd() {
    local cmd="$1"
    local description="$2"

    echo "Executing: $description"
    if $INFLUX_CMD "$cmd"; then
        echo "SUCCESS: $description"
        return 0
    else
        echo "WARNING: Failed to execute: $description"
        return 1
    fi
}

# Create user databases with retention policies
echo ""
echo "Creating user databases..."
for influx_db in $INFLUX_DATABASES; do
    echo "--- Processing database: $influx_db ---"

    execute_influx_cmd \
        "CREATE DATABASE \"$influx_db\"" \
        "Create database '$influx_db'"

    execute_influx_cmd \
        "ALTER RETENTION POLICY \"autogen\" ON \"$influx_db\" DURATION $INFLUX_DATABASE_RETENTION REPLICATION $INFLUX_DATABASE_REPLICATION SHARD DURATION $INFLUX_DATABASE_SHARD_DURATION DEFAULT" \
        "Set retention policy for '$influx_db' (${INFLUX_DATABASE_RETENTION}, shard: ${INFLUX_DATABASE_SHARD_DURATION})"
done

# Configure internal database
echo ""
echo "--- Processing internal database: $INTERNAL_INFLUX_DATABASE ---"
execute_influx_cmd \
    "CREATE DATABASE \"$INTERNAL_INFLUX_DATABASE\"" \
    "Create internal database"

execute_influx_cmd \
    "ALTER RETENTION POLICY \"autogen\" ON \"$INTERNAL_INFLUX_DATABASE\" DURATION $INTERNAL_INFLUX_DATABASE_RETENTION REPLICATION $INTERNAL_INFLUX_DATABASE_REPLICATION SHARD DURATION $INTERNAL_INFLUX_DATABASE_SHARD_DURATION DEFAULT" \
    "Set retention policy for internal database (${INTERNAL_INFLUX_DATABASE_RETENTION})"

# Display final database status
echo ""
echo "=== Database Configuration Summary ==="
$INFLUX_CMD "SHOW DATABASES" || echo "WARNING: Could not list databases"

echo ""
echo "=== Database initialization completed ==="
echo "Databases created: $INFLUX_DATABASES"
echo "Retention policy: $INFLUX_DATABASE_RETENTION"
echo "Shard duration: $INFLUX_DATABASE_SHARD_DURATION"
echo "Replication factor: $INFLUX_DATABASE_REPLICATION"