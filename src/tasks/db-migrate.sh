#!/bin/bash
#
# Task that migrates db and loads initial data
#

source "$(dirname "$0")/bootstrap.sh"

# Allows us to read user input below, assigns stdin to keyboard
exec < /dev/tty

function migrate {
    echo -n "Deleting and synchronizing database "
    if make resetdb
    then
        echo_success
    else
        echo_error
    fi
}

if source "$VIRTUAL_ENV/bin/activate"
then
    while true; do
        read -p "Do you wish to migrate db and reload init data (YES/no)? " yn
        if [ -z "$yn" ]
        then
            yn="yes"
        fi
        case $yn in
            yes|YES|Yes|Y|y) migrate; break;;
            no|NO|No|N|n ) break;;
            * ) echo_error "Please answer yes or no.";;
        esac
    done
else
    echo_error "Cannot found virtualenv"
fi
