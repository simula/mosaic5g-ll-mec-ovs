#!/bin/bash

source config

# Check if root
if [ "$(whoami)" != "root" ]; then
    exec sudo -- "$0" "$@"
fi

ovs-vsctl add-br edge -- set bridge edge protocols=$OF_VERSION # -- set bridge edge other-config:datapath-id=0000000000000004
sleep 1
ovs-vsctl add-port edge $EXT_INTERFACE
sleep 1
ovs-vsctl add-port edge s1u -- set Interface s1u type=gtp options:remote_ip=flow -- set Interface s1u type=gtp options:key=flow

ifconfig edge up
sleep 1
ifconfig $EXT_INTERFACE 0
sleep 1
ifconfig edge $EXT_IP
ovs-vsctl set bridge edge datapath_type=netdev
ovs-vsctl set-controller edge tcp:$CTRL_IP:$CTRL_PORT

