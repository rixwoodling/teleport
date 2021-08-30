#!/bin/bash
# teleport v1
# teleport a file from one computer to another
# https://github.com/rixwoodling/teleport/issues

# *** BE AWARE THIS SCRIPT REMOVES FILES! *** #

### functions ###

function arg_check {
    # validate all arguments
    for i in "$@"; do
        if [ -e ./"$i" ]; then :
        else echo "file not found"; exit 1
        fi
    done
}

function ip_check {
    # prompt for target ip
    read -p "enter target ip: " ipvar
    ping -c1 -w2 $ipvar &> /dev/null
    if [ $? -eq 0 ]; then :
    else echo "target ip timed out"; exit 1
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
    if ssh $ipvar "[ -d $dn ]" &> /dev/null; then :
    else ssh $ipvar "mkdir -p $dn" &> /dev/null; fi
}

function teleport {
    # copy to target then delete source
    scp -rp $dn/$bn $ipvar:$dn &&
    if [ -f "$dn/$bn" ]; then 
        echo "check for target directory"; \rm $dn/$bn &> /dev/null; fi
    if [ -d "$dn/$bn" ]; then 
        echo "create target directory", \rm -rf $dn/$bn &> /dev/null; fi
}

### main ###

if [ $# -eq 0 ]; then
    # verify arguments before continuing
    echo "nothing to teleport"; exit 1
elif [ $# -gt 0 ]; then
    if [ $# -eq 1 ]; then
        arg_check "$@"   # verify all arguments
        ip_check         # prompt for target ip
        source_var "$@"  # get working directory of first argument
        target_check     # if dir doesn't exist, create it over ssh
        teleport         # copy to target then delete source
        var=$@
    elif [ $# -gt 1 ]; then
        echo "one file at a time on the teleporter"
        exit 1
    fi
    echo "thanks for the ride, pardner!"
fi



