#!/usr/bin/env bash

declare -r hostname="$(hostname -s)"
declare -r rmq_node_idx="${1:-1}"

if (( rmq_node_idx < 1 || rmq_node_idx > 3 ))
then
    echo '[ERROR] first argument must be 1, 2 or 3' 2>&1
    exit 1
fi

declare -r rmq_nodename="rabbit-$rmq_node_idx@$hostname"
declare -ri base_idx="$((rmq_node_idx - 1))"

declare -ri rmq_node_port="$((base_idx + 5682))"
declare -ri rmq_management_port="$((base_idx + 15682))"

make -C "$HOME/development/rabbitmq/rabbitmq-server" \
    PLUGINS='rabbitmq_management rabbitmq_top rabbitmq_federation rabbitmq_federation_management' \
    RABBITMQ_CONFIG_FILE="$HOME/development/lukebakken/rabbitmq/conf/rabbitmq.conf" \
    RABBITMQ_NODENAME="$rmq_nodename" \
    RABBITMQ_NODE_PORT="$rmq_node_port" \
    RABBITMQ_BASE="/tmp/rabbitmq-test-instances/$rmq_nodename" \
    RABBITMQ_PID_FILE="/tmp/rabbitmq-test-instances/$rmq_nodename/$rmq_nodename.pid" \
    RABBITMQ_LOG_BASE="/tmp/rabbitmq-test-instances/$rmq_nodename/log" \
    RABBITMQ_MNESIA_BASE="/tmp/rabbitmq-test-instances/$rmq_nodename/mnesia" \
    RABBITMQ_MNESIA_DIR="/tmp/rabbitmq-test-instances/$rmq_nodename/mnesia/$rmq_nodename" \
    RABBITMQ_QUORUM_DIR="/tmp/rabbitmq-test-instances/$rmq_nodename/mnesia/$rmq_nodename/quorum" \
    RABBITMQ_STREAM_DIR="/tmp/rabbitmq-test-instances/$rmq_nodename/mnesia/$rmq_nodename/stream" \
    RABBITMQ_FEATURE_FLAGS_FILE="/tmp/rabbitmq-test-instances/$rmq_nodename/feature_flags" \
    RABBITMQ_PLUGINS_DIR="/home/lbakken/development/rabbitmq/rabbitmq-server/plugins" \
    RABBITMQ_PLUGINS_EXPAND_DIR="/tmp/rabbitmq-test-instances/$rmq_nodename/plugins" \
    RABBITMQ_SERVER_START_ARGS="-ra wal_sync_method sync -rabbit loopback_users [] -rabbitmq_management listener [{port,$rmq_management_port}]" \
    RABBITMQ_ENABLED_PLUGINS_FILE="/tmp/rabbitmq-test-instances/$rmq_nodename/enabled_plugins" \
    run-broker
