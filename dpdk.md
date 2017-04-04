# how to recover a device from dpdk

The command you need is `dpdk_nic_bind.py`. It's somewhere in the dpdk
code, which is under one or more of the p4-vSwitch directories.

```
39  python dpdk_nic_bind.py --help
40  python dpdk_nic_bind.py --status
41  sudo python dpdk_nic_bind.py -u 0000:02:00.1
42  sudo python dpdk_nic_bind.py -u 0000:02:00.2
43  sudo ifconfig eth1 up
44  python dpdk_nic_bind.py --status
45  ifconfig -a
46  ifup
47  sudo ifup eth1
48  python dpdk_nic_bind.py --help
49  sudo lspci
50  sudo find /sys | grep drivers.*02:00
51  python dpdk_nic_bind.py --help
52  python dpdk_nic_bind.py -b igb 02:00.1 02:00.2
53  sudo python dpdk_nic_bind.py -b igb 02:00.1 02:00.2
54  ifconfig -a
```
