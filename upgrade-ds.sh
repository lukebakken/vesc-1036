#!/bin/bash

set -o errexit
set -o nounset

readonly dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
# shellcheck source=common.sh
source "$dir/common.sh"

echo "[INFO] upgrading 'ds' cluster!"
declare -i rmq_node_idx=0

for rmq_node_idx in 1 2 3
do
    rmq_nodename="$(make_node_name "$rmq_node_idx")"
    "$HOME/development/rabbitmq/rabbitmq-server/sbin/rabbitmq-upgrade" -n "$rmq_nodename" drain
    sleep 10
    stop_node "$rmq_node_idx"
    start_node "$rmq_node_idx"
done
