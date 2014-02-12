#!/bin/sh
#
# Task checking that bower.json or package.json is identical to previous revision
#

source "$(dirname "$0")/bootstrap.sh"

bower_diff=`git diff @{-1}:bower.json bower.json`

if [ ! -z "$bower_diff" ]
then
    echo_info "Installing Bower dependencies..."
    bower install
    echo_success
else
    echo_info "Bower is up to date"
fi

npm_diff=`git diff @{-1}:package.json package.json`

if [ ! -z "$npm_diff" ]
then
    echo_info "Installing npm dependencies..."
    npm install
    echo_success
else
    echo_info "npm is up to date"
fi
