#!/bin/bash
CUR_DIR=`pwd`

# Check if root
if [ "$(whoami)" != "root" ]; then
    exec sudo -- "$0" "$@"
fi

# Download latest OVS-2.5 (LTS) sources
cd $CUR_DIR
rm -rf ovs
rm -rf /usr/local/etc/openvswitch
git clone https://github.com/openvswitch/ovs.git
cd ovs/

# Apply GTP patch 
git checkout branch-2.7
git am < $CUR_DIR/0001-Basic-GTP-U-tunnel-implementation-in-ovs.patch
git am < $CUR_DIR/0001-4.6-Fix-the-incompatible-GTP-tunnel-patch-for-ovs-2..patch
git am < $CUR_DIR/0001-Fix-incorrect-Ethernet-header-when-receiving-GTP-pac.patch

./boot.sh
./configure --with-linux=/lib/modules/`uname -r`/build
make clean
make
make install
make modules_install

rmmod openvswitch
modprobe -a `modinfo -F depends $CUR_DIR/ovs/datapath/linux/openvswitch.ko | sed 's/,/ /g'` # Install the dependencies

insmod $CUR_DIR/ovs/datapath/linux/openvswitch.ko
insmod $CUR_DIR/ovs/datapath/linux/vport-gtp.ko

# Initialize the configuration database
mkdir -p /usr/local/etc/openvswitch
ovsdb-tool create /usr/local/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema
