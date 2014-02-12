#!/bin/sh
#
# Helper functions for priting
#

function echo_clr {
    echo -e "\x1B$2$1\x1B[00m\n"
}

function echo_success {
    msg=$1
    if [ -z "$msg" ]
    then
            msg="successful"
    fi
    echo_clr "$msg" "[00;32m"
}

function echo_error {
    msg=$1
    if [ -z "$msg" ]
    then
            msg="failed"
    fi
    echo_clr "$msg" "[00;31m"
}

function echo_info {
    echo_clr "$1" "[00;36m"
}
