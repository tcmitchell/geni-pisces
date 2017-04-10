#define ETHERTYPE_IPV4 0x0800
#define ETHERTYPE_VLAN 0x8100

parser start {
  return parse_ethernet;
}

parser parse_ethernet {
  extract(ethernet);
  return select(latest.etherType) {
    ETHERTYPE_IPV4: parse_ipv4;
    ETHERTYPE_VLAN: parse_vlan;
    default: ingress;
  }
}

/*
 * For an example of handling nested VLANs see
 * https://github.com/p4lang/papers/blob/master/sosr15/DC.p4/includes/parser.p4
 */
parser parse_vlan {
  extract(vlan_tag);
  return select(latest.etherType) {
    ETHERTYPE_IPV4: parse_ipv4;
    default: ingress;
  }
}

parser parse_ipv4 {
  extract(ipv4);
  return ingress;
}
