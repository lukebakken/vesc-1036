#!/usr/bin/env bash

set -o xtrace
set -o errexit

readonly cluster="${1:-us}"

set -o nounset

echo "[INFO] upgrading '$cluster' cluster!"

for SVC in "rmq0-$cluster" "rmq1-$cluster" "rmq2-$cluster"
do
    # NB: https://github.com/docker/compose/issues/1262
    container_id="$(docker compose ps -q "$SVC")"
    docker exec "$container_id" /opt/rabbitmq/sbin/rabbitmq-upgrade drain
    sleep 10
    docker compose stop "$SVC"
    docker compose up --detach --no-deps "$SVC"
done
