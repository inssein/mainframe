#!/usr/bin/env bash
#
# Run a command on all nodes in the cluster.
#
set -eufo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage:"
    echo "  $0 <command>"
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi

COMMAND=$1
NODES=$(terraform -chdir=$ROOT/../terraform/bootstrap output --json nodes)

echo $NODES | jq -c -r '.[].hostname' | while read i; do
    ssh -n dietpi@$i "$1"
done