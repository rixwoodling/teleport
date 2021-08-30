#!/bin/bash
# teleport v1
# teleport a file from one computer to another
# https://github.com/rixwoodling/teleport/issues


### functions ###

function arg_check {
    # validate all arguments
    for i in "$@"; do
        if [ -e "$i" ]; then :
        else echo "invalid files or folders"; exit 1
        fi
    done
}

function ip_check {
    # prompt for target ip
    read -p "enter target ip: " ipvar
    ping -c1 -w2 $ipvar &> /dev/null
    if [ $? -eq 0 ]; then :
    else
        echo "target ip timed out"; exit 1
    fi
}

function source_var {
    # get working directory of first argument
    for i in "$@"; do
        bn=$(basename "$i")
        dn=$(cd $(dirname "$i") && pwd -P)
    done
}

function target_check {
    # if dir doesn't exist, create it over ssh
    if ssh $ipvar "[ -d $dn ]"; then :
    else ssh $ipvar "mkdir -p $dn"; fi
}

function teleport {
    scp -rp $dn/$bn $ipvar:$dn
    rm $bn
}

### main ###

if [ $# -eq 0 ]; then
    # verify arguments before continuing
    echo "nothing to teleport"; exit 1
elif [ $# -gt 0 ]; then
    if [ $# -eq 1 ]; then
        arg_check "$@"   # verify arguments
        ip_check         # prompt for target ip
        source_var "$@"  # get working directory
        target_check     # create target directory if missing
        teleport         # copy to target then delete source
        var=$@
        echo "teleporting $var over to $ipvar"
        # ...
    elif [ $# -gt 1 ]; then
        echo "one file at a time on the teleporter"
        exit 1
    fi
    echo "thanks for the ride, pardner!"
fi



