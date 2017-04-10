This P4 example is based on several example programs:

* The p4app [single_switch_mininet.py](https://github.com/p4lang/p4app/blob/master/docker/scripts/mininet/single_switch_mininet.py) topology program
* The p4app [simple router example](https://github.com/p4lang/p4app/tree/master/examples/simple_router.p4app)
* The mininet [VLANHost example](https://github.com/mininet/mininet/blob/master/examples/vlanhost.py)

This p4app example is different from the above sources as follows:

1. The mininet VLANHost example relies on vconfig, which is not found on
Ubuntu 16.04. I adapted the example to use the `ip` command instead.
2. The p4app simple router example provided the basis for the P4 program. I
(back)ported it from P4-16 to P4-14 so that it would run on
[PISCES]() and added basic VLAN handling.
3. I crafted the custom topology by starting with the default mininet
topology driver, single_switch_mininet. I added the VLANHost support
and adapted the command line arguments as needed to match the invocation
of a custom topology program.
