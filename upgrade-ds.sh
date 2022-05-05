#!/bin/bash

set -o errexit
set -o nounset

readonly dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
# shellcheck source=common.sh
source "$dir/common.sh"

echo "[INFO] upgrading 'ds' cluster!"

declare -i _upgrade_idx=0
for (( _upgrade_idx=1; _upgrade_idx <= 3; _upgrade_idx++ ))
do
    _upgrade_nodename="$(make_node_name "$_upgrade_idx")"
    "$HOME/development/rabbitmq/rabbitmq-server_v3.8.x/sbin/rabbitmq-upgrade" -n "$_upgrade_nodename" drain
    stop_node "$_upgrade_idx"
    sleep 5
    start_node "$_upgrade_idx"
done
