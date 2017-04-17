# pre-populate ARP caches

to show the arp cache:

```
arp -a -n
```

To add a static entry:

```
# map IP address to MAC address
sudo arp -s 10.10.1.2 02:18:61:cd:33:90
```

# Dump PISCES rule tables

To see what packets are flowing through the rule tables:

```
sudo ovs/utilities/ovs-ofctl --protocols=OpenFlow15 dump-flows br0
```

This shows where packets are being dropped, for instance.

# To Do

1. Try to use IP addresses instead of hex representation. There
   is an example of this in ovs/include/p4/examples/simple_router.sh
   (I think). It would be much easier for folks to understand.
