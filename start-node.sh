#!/bin/bash

readonly dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
# shellcheck source=common.sh
source "$dir/common.sh"

declare -ri rmq_node_idx="${1:-1}"
check_node_idx "$rmq_node_idx"

start_node "$rmq_node_idx"
