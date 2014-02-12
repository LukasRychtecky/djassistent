#!/bin/bash
#
# Task checking that requirements.txt is identical that pip freeze and updating packages from requirements.txt
#

source "$(dirname "$0")/bootstrap.sh"

echo "Purging pyc files and empty directories..."

# Start from the repository root.
cd ./$(git rev-parse --show-cdup)

make clean

if source "$VIRTUAL_ENV/bin/activate"
then

    echo -n "Checking if virtualenv needs to update packages "
    touch "$WORK_DIR/requirements.txt"

    if grep -vxFf <(pip freeze) "$WORK_DIR/requirements.txt"
    then
        echo -n "Installing packages "
        make pip
        echo_success
    else
        echo_info "Packages need not to be updated"
    fi

    make checkdb
else
    echo_error "Cannot found virtualenv"
fi

make checkjspkgs
make checkjs
