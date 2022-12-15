#!/bin/bash

INFLUXDB_INIT_PORT="${INFLUXDB_INIT_PORT:-8086}"
INFLUX_DATABASE="${INFLUX_DATABASE:-telegraf}"
INFLUX_DATABASE_RETENTION="${INFLUX_DATABASE_RETENTION:-7d}"
INFLUX_DATABASE_REPLICATION="${INFLUX_DATABASE_REPLICATION:-1}"

if [ ! -z "${INFLUXDB_ADMIN_USER}" ] && [ -z "${INFLUXDB_ADMIN_PASSWORD}" ]; then
    INFLUX_CMD="influx -host 127.0.0.1 -port $INFLUXDB_INIT_PORT -username ${INFLUXDB_ADMIN_USER} -password ${INFLUXDB_ADMIN_PASSWORD} -execute "
else
    INFLUX_CMD="influx -host 127.0.0.1 -port $INFLUXDB_INIT_PORT -execute "
fi

$INFLUX_CMD "CREATE DATABASE \"$INFLUX_DATABASE\""
$INFLUX_CMD "ALTER RETENTION POLICY \"autogen\" ON \"$INFLUX_DATABASE\" DURATION $INFLUX_DATABASE_RETENTION REPLICATION $INFLUX_DATABASE_REPLICATION DEFAULT"