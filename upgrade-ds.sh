#!/bin/bash

set -o errexit
set -o nounset

readonly dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
# shellcheck source=common.sh
source "$dir/common.sh"

readonly rmq_src_start="$1"
readonly rmq_src_end="${2:-$rmq_src_start}"

echo "[INFO] upgrading 'ds' cluster!"

declare -i _upgrade_idx=0
for (( _upgrade_idx=1; _upgrade_idx <= 3; _upgrade_idx++ ))
do
    _upgrade_nodename="$(make_node_name "$_upgrade_idx")"
    if [[ -x "$rmq_src_start/sbin/rabbitmq-upgrade" ]]
    then
        "$rmq_src_start/sbin/rabbitmq-upgrade" -n "$_upgrade_nodename" drain
    fi
    stop_node "$_upgrade_idx"
    sleep 5
    start_node "$_upgrade_idx" 5672 "$rmq_src_end"
done
