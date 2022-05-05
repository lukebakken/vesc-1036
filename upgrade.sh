#!/usr/bin/env bash

set -o errexit

readonly cluster="${1:-us}"

set -o nounset

echo "[INFO] upgrading '$cluster' cluster!"

set +o errexit
for idx in 0 1 2
do
    svc="rmq$idx-$cluster"
    # NB: https://github.com/docker/compose/issues/1262
    container_id="$(docker compose ps -q "$svc")"
    docker exec "$container_id" /opt/rabbitmq/sbin/rabbitmq-upgrade drain
    docker compose stop "$svc"
    if (( idx < 2 ))
    then
        sleep 10
    fi
    docker compose up --detach --no-deps "$svc"
done
