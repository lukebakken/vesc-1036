#!/bin/bash

declare -r hostname="$(hostname -s)"

function check_node_idx
{
    local -i node_idx="$1"
    if (( node_idx < 1 || node_idx > 3 ))
    then
        echo "$(date '+%c')[ERROR] node_index must be 1, 2 or 3" 2>&1
        exit 1
    fi
}

function await_node
{
    local -ri _await_node_idx="$1"
    local -ri _await_node_src_base="${2:-$HOME/development/rabbitmq/rabbitmq-server}"

    local -r _await_nodename="$(make_node_name "$_await_node_idx")"
    local -r _await_pid_file="/tmp/rabbitmq-test-instances/$_await_nodename/$_await_nodename.pid"
    local -r _await_rmqctl="$_await_node_src_base/sbin/rabbitmqctl"
    "$_await_rmqctl" -n "$_await_nodename" wait --timeout 60 "$_await_pid_file"
    "$_await_rmqctl" -n "$_await_nodename" await_startup
}

function make_node_name
{
    local -i _make_node_idx="$1"
    echo "rabbit-$_make_node_idx@$hostname"
}

function drain_node
{
    local -r _drain_rmq_nodename="$1"
    "$HOME/development/rabbitmq/rabbitmq-server/sbin/rabbitmq-upgrade" -n "$_drain_rmq_nodename" drain
}

function stop_node
{
    local -ri _stop_node_idx="$1"

    local -r _stop_nodename="$(make_node_name "$_stop_node_idx")"
    local -r _stop_pid_file="/tmp/rabbitmq-test-instances/$_stop_nodename/$_stop_nodename.pid"

    if [[ -s "$_stop_pid_file" ]]
    then
        local -ri _stop_pid="$(< "$_stop_pid_file")"
        if (( _stop_pid > 0 ))
        then
            echo "$(date '+%c') [INFO] stopping RabbitMQ with pid: '$_stop_pid'"
            kill -TERM "$_stop_pid"

            echo "$(date '+%c') [INFO] waiting for process to exit"
            while kill -0 "$_stop_pid" >/dev/null 2>&1
            do
                sleep 1
                echo "$(date '+%c') [INFO] waiting for process to exit"
            done
        else
            echo "$(date '+%c') [WARN] pid is not greater than zero!"
        fi
    else
        echo "$(date '+%c') [WARN] file is not present: '$_stop_pid_file'"
    fi
}

function start_node
{
    local -ri _start_node_idx="$1"
    local -ri _start_base_port="${2:-5672}"
    local -r _start_node_src_base="${3:-$HOME/development/rabbitmq/rabbitmq-server}"

    if [[ ! -d "$_start_node_src_base" ]]
    then
        echo "$(date '+%c')[ERROR] could not find directory '$_start_node_src_base'"  2>&1
        return 1
    fi

    local -r _start_nodename="$(make_node_name "$_start_node_idx")"
    local -ri _start_base_idx="$((_start_node_idx - 1))"
    local -ri rmq_node_port="$((_start_base_idx + _start_base_port))"
    local -ri rmq_management_port="$((rmq_node_port + 10000))"
    make -C "$_start_node_src_base" \
        PLUGINS='rabbitmq_management rabbitmq_top rabbitmq_federation rabbitmq_federation_management' \
        RABBITMQ_CONFIG_FILE="$HOME/development/lukebakken/rabbitmq/conf/rabbitmq.conf" \
        RABBITMQ_NODENAME="$_start_nodename" \
        RABBITMQ_NODE_PORT="$rmq_node_port" \
        RABBITMQ_BASE="/tmp/rabbitmq-test-instances/$_start_nodename" \
        RABBITMQ_PID_FILE="/tmp/rabbitmq-test-instances/$_start_nodename/$_start_nodename.pid" \
        RABBITMQ_LOG_BASE="/tmp/rabbitmq-test-instances/$_start_nodename/log" \
        RABBITMQ_MNESIA_BASE="/tmp/rabbitmq-test-instances/$_start_nodename/mnesia" \
        RABBITMQ_MNESIA_DIR="/tmp/rabbitmq-test-instances/$_start_nodename/mnesia/$_start_nodename" \
        RABBITMQ_QUORUM_DIR="/tmp/rabbitmq-test-instances/$_start_nodename/mnesia/$_start_nodename/quorum" \
        RABBITMQ_STREAM_DIR="/tmp/rabbitmq-test-instances/$_start_nodename/mnesia/$_start_nodename/stream" \
        RABBITMQ_FEATURE_FLAGS_FILE="/tmp/rabbitmq-test-instances/$_start_nodename/feature_flags" \
        RABBITMQ_PLUGINS_DIR="$_start_node_src_base/plugins" \
        RABBITMQ_PLUGINS_EXPAND_DIR="/tmp/rabbitmq-test-instances/$_start_nodename/plugins" \
        RABBITMQ_SERVER_START_ARGS="-ra wal_sync_method sync -rabbit loopback_users [] -rabbitmq_management listener [{port,$rmq_management_port}]" \
        RABBITMQ_ENABLED_PLUGINS_FILE="/tmp/rabbitmq-test-instances/$_start_nodename/enabled_plugins" \
        start-background-broker
}
