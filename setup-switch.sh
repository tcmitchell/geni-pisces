#!/usr/bin/env bash

# ----------------------------------------------------------------------
# This script executes the steps found in
#
#     https://github.com/P4-vSwitch/vagrant/blob/master/setup-switch.sh
#
# This script uses a PISCES_HOME environment variable so that the
# directory "/home/vagrant" is not hardcoded. This allows the software
# to be installed in another directory, like the user's home
# directory.
# ----------------------------------------------------------------------

set -e
set -x

PISCES_HOME=`pwd`
if [ -d /home/vagrant ]; then
  PISCES_HOME=/home/vagrant
fi

sudo apt-get install -y python-setuptools python-yaml

# Clone and install p4-hlir
cd "${PISCES_HOME}"
git clone https://github.com/p4lang/p4-hlir.git
cd p4-hlir/
sudo python setup.py install

# Clone and install p4c-behavioral
cd "${PISCES_HOME}"
git clone https://github.com/P4-vSwitch/p4c-behavioral.git
cd p4c-behavioral/
git checkout ovs
sudo python setup.py install

# Clone ovs
cd "${PISCES_HOME}"
git clone https://github.com/P4-vSwitch/ovs.git
cd ovs/
git checkout p4
git submodule update --init

# Build DPDK
cd "${PISCES_HOME}/ovs/deps/dpdk"
patch -p1 -N < ../../setup-scripts/patches/dpdk.patch
make -j 2 install T=x86_64-native-linuxapp-gcc

# Setup DPDK-specific environment variables
export RTE_SDK="${PISCES_HOME}/ovs/deps/dpdk"
export RTE_TARGET=x86_64-native-linuxapp-gcc
export DPDK_DIR=$RTE_SDK
export DPDK_BUILD=$DPDK_DIR/$RTE_TARGET/

# Note: You may want to append these variables in the `~/.bashrc` file. This way you don't have to execute these whenever you
# open a new terminal.

# Setup DPDK kernel modules
cd "${PISCES_HOME}"
sudo modprobe uio
sudo insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko
sudo insmod $RTE_SDK/$RTE_TARGET/kmod/rte_kni.ko "lo_mode=lo_mode_ring"

# Add eth1 and eth2 interfaces to DPDK
sudo ifconfig eth1 down
sudo $RTE_SDK/tools/dpdk_nic_bind.py -b igb_uio eth1
sudo ifconfig eth2 down
sudo $RTE_SDK/tools/dpdk_nic_bind.py -b igb_uio eth2

# To view these interfaces run the following command:
# $RTE_SDK/tools/dpdk_nic_bind.py --status

# Configure Huge Pages
cd "${PISCES_HOME}"
sudo mkdir -p /mnt/huge
(mount | grep hugetlbfs) > /dev/null || sudo mount -t hugetlbfs nodev /mnt/huge
sudo sh -c 'echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages'

# Note: you can verify if huge pages are configured properly using the following command:
# grep -i huge /proc/meminfo

# Build OVS (first time only)
cd "${PISCES_HOME}/ovs/"
./boot.sh
./configure --with-dpdk=$DPDK_BUILD CFLAGS="-g -O2 -Wno-cast-align" \
            p4inputfile=./include/p4/examples/l2_switch/l2_switch.p4 \
            p4outputdir=./include/p4/src
make -j 2

# Create OVS database files and folders
sudo mkdir -p /usr/local/etc/openvswitch
sudo mkdir -p /usr/local/var/run/openvswitch
cd "${PISCES_HOME}/ovs/ovsdb/"
sudo ./ovsdb-tool create /usr/local/etc/openvswitch/conf.db ../vswitchd/vswitch.ovsschema
