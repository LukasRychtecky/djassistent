#!/bin/bash
#
# Task checking that requirements.txt is identical that pip freeze and updating requirements.txt
#

source "$(dirname "$0")/bootstrap.sh"

if source "$VIRTUAL_ENV/bin/activate"
then
    touch "$WORK_DIR/requirements.txt"

    if grep -vxFf <(cat "$WORK_DIR/requirements.txt" "$WORK_DIR/.pipignore" 2> /dev/null) <(pip freeze) > /dev/null
    then
        echo -n "Updating requirements "
        updated_packages="$(\grep -vxFf <(cat "$WORK_DIR/requirements.txt" "$WORK_DIR/.pipignore" 2> /dev/null) <(pip freeze) | tr '\n' ' ')"
        if [ -f "$WORK_DIR/.pipignore" ]
        then
            pip freeze | \grep -v $(cat "$WORK_DIR/.pipignore") > "$work_dir/requirements.txt"
        else
            pip freeze > "$WORK_DIR/requirements.txt"
        fi
        git add "$WORK_DIR/requirements.txt"
        echo_success "success (Updated packages: $updated_packages)"
    else
        echo_info "File requirements.txt need not be updated"
    fi
else
    echo_error "Cannot found virtualenv"
fi
