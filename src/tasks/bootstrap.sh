#!/bin/bash
#
# Bootstrap loader
#

source_dir="$(dirname "$0")"

WORK_DIR="$(git rev-parse --show-toplevel)"
VIRTUAL_ENV="$WORK_DIR/var/ve"
INIT_DATA_DIR="$WORK_DIR/data/dev"

source "$source_dir/msg.sh"
