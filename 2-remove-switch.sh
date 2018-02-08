#!/bin/bash

source config

# Check if root
if [ "$(whoami)" != "root" ]; then
    exec sudo -- "$0" "$@"
fi

ovs-vsctl del-br edge
sleep 1
ifconfig $EXT_INTERFACE 0
