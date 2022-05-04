#!/bin/bash

set -o errexit
set -o nounset

readonly dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
# shellcheck source=common.sh
source "$dir/common.sh"

echo "[INFO] upgrading 'ds' cluster!"
declare -i rmq_node_idx=0

for _upgrade_idx in 1 2 3
do
    _upgrade_nodename="$(make_node_name "$_upgrade_idx")"
    "$HOME/development/rabbitmq/rabbitmq-server_v3.8.x/sbin/rabbitmq-upgrade" -n "$_upgrade_nodename" drain
    # sleep 5
    stop_node "$_upgrade_idx"
    start_node "$_upgrade_idx"
done
