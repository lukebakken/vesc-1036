#!/bin/bash

declare -r hostname="$(hostname -s)"

function check_node_idx
{
    local -i node_idx="$1"
    if (( node_idx < 1 || node_idx > 3 ))
    then
        echo '[ERROR] node_index must be 1, 2 or 3' 2>&1
        exit 1
    fi
}

function make_node_name
{
    local -i node_idx="$1"
    echo "rabbit-$node_idx@$hostname"
}

function drain_node
{
    local -r rmq_nodename="$1"
    "$HOME/development/rabbitmq/rabbitmq-server/sbin/rabbitmq-upgrade" -n "$rmq_nodename" drain
}

function stop_node
{
    local -ri rmq_node_idx="$1"
    local -r rmq_nodename="$(make_node_name "$rmq_node_idx")"
    "$HOME/development/rabbitmq/rabbitmq-server/sbin/rabbitmqctl" -n "$rmq_nodename" shutdown
}

function start_node
{
    local -ri rmq_node_idx="$1"
    local -ri rmq_base_port="${2:-5682}"
    local -r rmq_nodename="$(make_node_name "$rmq_node_idx")"
    local -ri base_idx="$((rmq_node_idx - 1))"
    local -ri rmq_node_port="$((base_idx + rmq_base_port))"
    local -ri rmq_management_port="$((rmq_node_port + 10000))"
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
}
