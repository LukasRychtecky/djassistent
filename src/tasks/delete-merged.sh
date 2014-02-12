#!/bin/bash
#
# Task delete merged local and remote branches
#

source "$(dirname "$0")/bootstrap.sh"

EXCLUDE="master|next|release"

# local
git branch --merged remotes/origin/next | grep -v -E "$EXCLUDE" | xargs -n 1 git br -d

#remote
git branch -a --merged remotes/origin/next | grep -v -E "$EXCLUDE" | grep "public" | cut -d "/" -f 3 | xargs -n 1 git push --delete public
