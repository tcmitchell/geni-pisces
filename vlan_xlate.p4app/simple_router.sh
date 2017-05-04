#! /bin/sh -ve

# Please make sure that you update the path to the current OVS directory.
DIR=~/ovs/utilities

# For this test we will pre-populate ARP caches at the end-hosts

$DIR/ovs-ofctl --protocols=OpenFlow15 del-flows br0

# Verify Checksum (Table 0)
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=32768,ethernet_etherType=0x800 \
                                                    actions=calc_fields_verify(ipv4_hdrChecksum,csum16,fields:ipv4_version_ihl,ipv4_diffserv,ipv4_totalLen,ipv4_identification,ipv4_flags_fragOffset,ipv4_ttl,ipv4_protocol,ipv4_srcAddr,ipv4_dstAddr), \
                                                            resubmit(,1)"
# Accept VLAN packets too
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=32768,ethernet_etherType=0x8100 \
                                                    actions=calc_fields_verify(ipv4_hdrChecksum,csum16,fields:ipv4_version_ihl,ipv4_diffserv,ipv4_totalLen,ipv4_identification,ipv4_flags_fragOffset,ipv4_ttl,ipv4_protocol,ipv4_srcAddr,ipv4_dstAddr), \
                                                            resubmit(,1)"
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=0,priority=0 actions="

# VLAN translation (Table 1)
# Translate VLAN 260 -> 261 (0x104 -> 0x105); mask off pcp & cfi fields
# 258 == 0x102
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=1,priority=32768,vlan_tag_pcp_cfi_vid=0x104/0x0FFF \
                                                    actions=set_field:0x102->vlan_tag_pcp_cfi_vid, \
                                                            resubmit(,2)"
# Translate VLAN 261 -> 260
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=1,priority=32768,vlan_tag_pcp_cfi_vid=0x102/0x0FFF \
                                                    actions=set_field:0x104->vlan_tag_pcp_cfi_vid, \
                                                            resubmit(,2)"
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=1,priority=0 actions="

# IPv4 LPM (Table 2)
# If IPv4 destination address is 10.10.1.*, send out port 1 to 10.10.1.1
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=2,priority=32768,ipv4_dstAddr=0x0A0A0101/0xFFFFFF00 \
                                                    actions=set_field:0x0A0A0101->ingress_metadata_nhop_ipv4, \
                                                            set_field:1->reg0, \
                                                            set_field:63->ipv4_ttl, \
                                                            resubmit(,3)"
# If IPv4 destination address is 10.10.2.*, send out port 2 to 10.10.2.1
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=2,priority=32768,ipv4_dstAddr=0x0A0A0201/0xFFFFFF00 \
                                                    actions=set_field:0x0A0A0201->ingress_metadata_nhop_ipv4, \
                                                            set_field:2->reg0, \
                                                            set_field:63->ipv4_ttl, \
                                                            resubmit(,3)"
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=2,priority=0 actions="

# Forward (Table 3) (sets the destination MAC address)
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=3,priority=32768,ingress_metadata_nhop_ipv4=0x0A0A0101 \
                                                    actions=set_field:0x020358d670d9->ethernet_dstAddr, \
                                                            resubmit(,4)"
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=3,priority=32768,ingress_metadata_nhop_ipv4=0x0A0A0201 \
                                                    actions=set_field:0x025d052f5188->ethernet_dstAddr, \
                                                            resubmit(,4)"
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=3,priority=0 actions="

# Send Frame (Table 4) (sets the source MAC address)
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=4,priority=32768,reg0=1 \
                                                    actions=set_field:0x025105ad3d7c->ethernet_srcAddr, \
							    calc_fields_update(ipv4_hdrChecksum,csum16,fields:ipv4_version_ihl,ipv4_diffserv,ipv4_totalLen,ipv4_identification,ipv4_flags_fragOffset,ipv4_ttl,ipv4_protocol,ipv4_srcAddr,ipv4_dstAddr), \
                                                            deparse, \
                                                            output:NXM_NX_REG0[]"
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=4,priority=32768,reg0=2 \
                                                    actions=set_field:0x027b79b203f1->ethernet_srcAddr, \
							    calc_fields_update(ipv4_hdrChecksum,csum16,fields:ipv4_version_ihl,ipv4_diffserv,ipv4_totalLen,ipv4_identification,ipv4_flags_fragOffset,ipv4_ttl,ipv4_protocol,ipv4_srcAddr,ipv4_dstAddr), \
                                                            deparse, \
                                                            output:NXM_NX_REG0[]"
$DIR/ovs-ofctl --protocols=OpenFlow15 add-flow br0 "table=4,priority=0 actions="
