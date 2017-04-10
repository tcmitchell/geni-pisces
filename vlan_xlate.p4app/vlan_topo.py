#!/usr/bin/env python2

# Copyright 2013-present Barefoot Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from mininet.node import Host
from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI

from p4_mininet import P4Switch, P4Host

import argparse
from subprocess import PIPE, Popen
from time import sleep

parser = argparse.ArgumentParser(description='Mininet demo')
parser.add_argument('--behavioral-exe', help='Path to behavioral executable',
                    type=str, action="store", required=True)
parser.add_argument('--thrift-port', help='Thrift server port for table updates',
                    type=int, action="store", default=9090)
parser.add_argument('--num-hosts', help='Number of hosts to connect to switch',
                    type=int, action="store", default=2)
parser.add_argument('--mode', choices=['l2', 'l3'], type=str, default='l3')
parser.add_argument('--json', help='Path to JSON config file',
                    type=str, action="store", required=True)
parser.add_argument('--log-file', help='Path to write the switch log file',
                    type=str, action="store", required=False)
parser.add_argument('--pcap-dump', help='Dump packets on interfaces to pcap files',
                    type=str, action="store", required=False, default=False)
parser.add_argument('--switch-config', help='simple_switch_CLI script to configure switch',
                    type=str, action="store", required=False, default=False)
parser.add_argument('--cli-message', help='Message to print before starting CLI',
                    type=str, action="store", required=False, default=None)
parser.add_argument('--cli', help='CLI program',
                    type=str, action="store", required=False, default=None)

args = parser.parse_args()


class VLANHost(P4Host):
    "Host connected to VLAN interface"

    def config(self, vlan=100, **params):
        """Configure VLANHost according to (optional) parameters:
           vlan: VLAN ID for default interface"""

        r = super(VLANHost, self).config(**params)

        intf = self.defaultIntf()
        # remove IP from default, "physical" interface
        self.cmd('ifconfig %s inet 0' % intf)

        # create VLAN interface
        vlan_create_cmd = 'ip link add link %s name %s.%d type vlan id %d'
        vlan_create_cmd = vlan_create_cmd % (intf, intf, vlan, vlan)
        print vlan_create_cmd
        result = self.cmd(vlan_create_cmd)
        print 'vlan_create result = %r' % (result)

        # bring VLAN interface up
        vlan_up_cmd = 'ip link set %s.%d up'
        vlan_up_cmd = vlan_up_cmd % (intf, vlan)
        print vlan_up_cmd
        result = self.cmd(vlan_up_cmd)
        print 'vlan_up result = %r' % (result)

        # assign the host's IP to the VLAN interface
        self.cmd('ifconfig %s.%d inet %s' % (intf, vlan, params['ip']))
        # update the intf name and host's intf map
        newName = '%s.%d' % (intf, vlan)
        # update the (Mininet) interface to refer to VLAN interface name
        intf.name = newName
        # add VLAN interface to host's name to intf map
        self.nameToIntf[newName] = intf

        return r

    def describe(self, sw_addr=None, sw_mac=None):
        print "**********"
        print "Network configuration for: %s" % self.name
        print "Default interface: %s\t%s\t%s" % (
            self.defaultIntf().name,
            self.defaultIntf().IP(),
            self.defaultIntf().MAC()
        )
        if sw_addr is not None or sw_mac is not None:
            print "Default route to switch: %s (%s)" % (sw_addr, sw_mac)
        print "**********"


class SingleSwitchTopo(Topo):
    "Single switch connected to n (< 256) hosts."
    def __init__(self, sw_path, json_path, log_file,
                 thrift_port, pcap_dump, n, **opts):
        # Initialize topology and default options
        Topo.__init__(self, **opts)

        switch = self.addSwitch('s1',
                                sw_path = sw_path,
                                json_path = json_path,
                                log_console = True,
                                log_file = log_file,
                                thrift_port = thrift_port,
                                enable_debugger = True,
                                pcap_dump = pcap_dump)

        for h in xrange(n):
            host = self.addHost('h%d' % (h + 1),
                                ip = "10.0.%d.10/24" % h,
                                mac = '00:04:00:00:00:%02x' %h,
                                cls=VLANHost,
                                vlan=100 + h)
            print "Adding host", str(host)
            self.addLink(host, switch)


def main():
    num_hosts = args.num_hosts
    mode = args.mode

    topo = SingleSwitchTopo(args.behavioral_exe,
                            args.json,
                            args.log_file,
                            args.thrift_port,
                            args.pcap_dump,
                            num_hosts)
    net = Mininet(topo = topo,
                  host = P4Host,
                  switch = P4Switch,
                  controller = None)
    net.start()

    sw_mac = ["00:aa:bb:00:00:%02x" % n for n in xrange(num_hosts)]

    sw_addr = ["10.0.%d.1" % n for n in xrange(num_hosts)]

    for n in xrange(num_hosts):
        h = net.get('h%d' % (n + 1))
        if mode == "l2":
            h.setDefaultRoute("dev %s" % h.defaultIntf().name)
        else:
            h.setARP(sw_addr[n], sw_mac[n])
            h.setDefaultRoute("dev %s via %s" % (h.defaultIntf().name, sw_addr[n]))

    for n in xrange(num_hosts):
        h = net.get('h%d' % (n + 1))
        h.describe(sw_addr[n], sw_mac[n])

    sleep(1)

    if args.switch_config is not None:
        print
        print "Reading switch configuration script:", args.switch_config
        with open(args.switch_config, 'r') as config_file:
            switch_config = config_file.read()

        print "Configuring switch..."
        proc = Popen(["simple_switch_CLI"], stdin=PIPE)
        proc.communicate(input=switch_config)

        print "Configuration complete."
        print

    print "Ready !"

    if args.cli_message is not None:
        with open(args.cli_message, 'r') as message_file:
            print message_file.read()

    CLI(net)
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')
    main()
