#include "header.p4"
#include "parser.p4"

action _nop() {
}

action _drop() {
    drop();
}

action set_nhop(nhop_ipv4, port) {
  ingress_metadata.nhop_ipv4 = nhop_ipv4;
  standard_metadata.egress_spec = port;
  ipv4.ttl = ipv4.ttl - 1;
}

table ipv4_lpm {
  reads {
    ipv4.dstAddr: lpm;
  }
  actions {
    _drop;
    set_nhop;
    _nop;
  }
  size: 1024;
}


action set_dmac(dmac) {
  ethernet.dstAddr = dmac;
}

table forward {
  reads {
    ingress_metadata.nhop_ipv4: exact;
  }
  actions {
    set_dmac;
    _drop;
    _nop;
  }
  size: 512;
}


action rewrite_mac(smac) {
  ethernet.srcAddr = smac;
}

table send_frame {
  reads {
    standard_metadata.egress_port: exact;
  }
  actions {
    rewrite_mac;
    _drop;
    _nop;
  }
  size: 256;
}


control ingress {
  apply(ipv4_lpm);
  apply(forward);
}

control egress {
  apply(send_frame);
}
