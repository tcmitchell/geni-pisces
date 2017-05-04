## Allocate topology

PISCES requires Ubuntu 14.04 at this time. Please be sure you are using
an Ubuntu 14.04 image in your request RSpec. (I forget what the dependency
really is.)

See the [sample request rspec](request-rspec.xml). Each RSpec must be
hardwired to a specific bare metal node. There are three items that
need to be populated with actual values in the
[sample request rspec](request-rspec.xml).

| Placeholder                     | Description |
| -----------                     | ----------- |
| INSERT PC COMPONENT ID          | component id of the bare metal node |
| INSERT INTERFACE COMPONENT ID 1 | component id of a network interface on the node |
| INSERT INTERFACE COMPONENT ID 2 | component id of a 2nd network interface on the node |

## Update OS

Update the OS. See [Update Notes]() below for help.

```shell
sudo apt-get update
sudo apt-get upgrade -y

```

After the update is complete, reboot the host:

```shell
sudo reboot

```

### Update Notes

1. Always "keep your currently-installed version" when prompted
2. Updating GRUB:
  1. keep the local version currently installed; Ok
  2. Ok (previously installed on disk no longer present)
  3. Select NO devices; Ok
  4. Continue without installing GRUB?  Yes

## Use ansible to configure the PISCES host

1. Install ansible

    ```
    sudo apt-get install -y ansible

    ```

2. Clone geni-pisces repository

    ```
    git clone https://github.com/tcmitchell/geni-pisces

    ```

3. Install latest ansible

    ```
    cd geni-pisces
    ansible-playbook -i localhost, -c local ansible/ansible.yml

    ```

4. Install PISCES dependencies

   ```
   ansible-playbook -i localhost, -c local ansible/pisces.yml

   ```

## Hand off interfaces to DPDK

_Note: `eth0` is the control plane. DO NOT hand off eth0 to DPDK._

For each interface to be used in P4:

```
export P4_INTF=eth1

sudo ifconfig "${P4_INTF}" down
sudo ~/ovs/deps/dpdk/tools/dpdk_nic_bind.py -b igb_uio "${P4_INTF}"
```

You can view the interfaces in DPDK:

```
~/ovs/deps/dpdk/tools/dpdk_nic_bind.py --status
```

## Build OVS with your P4 program

```
export MY_P4="${HOME}"/geni-pisces/vlan_xlate.p4app/simple_router.p4
export DPDK_BUILD="${HOME}"/ovs/deps/dpdk/x86_64-native-linuxapp-gcc
cd ~/ovs
./boot.sh
./configure --with-dpdk="${DPDK_BUILD}" \
            CFLAGS="-g -O2 -Wno-cast-align" \
            p4inputfile="${MY_P4}" \
            p4outputdir=./include/p4/src
make -j 2
```

## Create OVS database

```
sudo mkdir -p /usr/local/etc/openvswitch
sudo mkdir -p /usr/local/var/run/openvswitch
cd "${HOME}"/ovs/ovsdb/
sudo ./ovsdb-tool create /usr/local/etc/openvswitch/conf.db ../vswitchd/vswitch.ovsschema
```

# Running OVS

Running OVS with your P4 program requires two terminal windows.

Run `ovsdb-server` in terminal 1:

```
cd "${HOME}"/ovs/ovsdb
sudo ./ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
                    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                    --pidfile
```

Run `ovs-vswitchd` in terminal 2:

```
cd "${HOME}"/ovs/vswitchd
sudo ./ovs-vswitchd --dpdk -c 0x1 -n 4 -- unix:/usr/local/var/run/openvswitch/db.sock --pidfile
```

## Create an OVS bridge

This only needs to be done once, and requires a third terminal window.
This must be done when `ovsdb-server` and `ovs-vswitchd` are running.

```
cd "${HOME}"/ovs/utilities
sudo ./ovs-vsctl --no-wait init
sudo ./ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
sudo ./ovs-vsctl set bridge br0 protocols=OpenFlow15
sudo ./ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk0 type=dpdk
sudo ./ovs-vsctl add-port br0 dpdk1 -- set Interface dpdk1 type=dpdk
```

# Install the P4 match/action tables

```
sudo "${HOME}"/geni-pisces/vlan_xlate.p4app/simple_router.sh
```

## To clear the P4 match/action tables:

```
sudo "${HOME}"/ovs/utilities/ovs-ofctl --protocols=OpenFlow15 del-flows br0
```

# Manually install ARP entries

The PISCES-configured OVS switch will drop ARP packets, so ARP tables
must be manually configured on the client VMs. Each VM needs an entry
mapping the switch's IP address and MAC address
_on the same VLAN as the VM_.

To add a static entry:

```
# map IP address to MAC address
sudo arp -s 10.10.1.2 02:18:61:cd:33:90
```

To show the arp cache, including static entries:

```
arp -a -n
```


# Future Work

1. Add ARP replies so ARP doesn't have to be hardcoded
2. Can the VLAN example use a single data plane interface?
3. Can the example run on Ubuntu 16? If not, why not?
4. Develop a custom protocol example
