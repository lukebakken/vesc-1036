#!/usr/bin/env bash

declare -r hostname="$(hostname -s)"
declare -r rmq_node_idx="${1:-1}"

if (( rmq_node_idx < 1 || rmq_node_idx > 3 ))
then
    echo '[ERROR] first argument must be 1, 2 or 3' 2>&1
    exit 1
fi

declare -r rmq_nodename="rabbit-$rmq_node_idx@$hostname"
"$HOME/development/rabbitmq/rabbitmq-server/sbin/rabbitmqctl" -n "$rmq_nodename" shutdown
