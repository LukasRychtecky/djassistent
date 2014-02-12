#!/bin/bash
#
# Hook checking that Client side files need to be recompiled
#

source "$(dirname "$0")/bootstrap.sh"

changed_cs_files=`git diff --name-only HEAD@{1}.. | grep ".coffee"`

if [ ! -z "$changed_cs_files" ]
then
    echo_info "Client side files have been changed."

    while true; do
        read -p "Would you like recompile them? (NO/yes)? It takes less than 30s. " answer
        if [ -z "$answer" ]
        then
            answer="no"
        fi
        case $answer in
            yes|YES|Yes|y|Y )
                make buildjs;
                break;;
            no|NO|No|n|N ) break;;
            * ) echo_error "Please answer yes or no.";;
        esac
    done
else
    echo_info "Client script is up to date"
fi
