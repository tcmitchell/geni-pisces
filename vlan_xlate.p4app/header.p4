#ifndef __HEADER_H__
#define __HEADER_H__ 1

header_type ingress_metadata_t {
  fields {
    nhop_ipv4 : 32;
  }
}

metadata ingress_metadata_t ingress_metadata;

header_type intrinsic_metadata_t {
  fields {
    ingress_global_timestamp : 48;
    lf_field_list : 32;
    mcast_grp : 16;
    egress_rid : 16;
  }
}

metadata intrinsic_metadata_t intrinsic_metadata;

header_type ethernet_t {
  fields {
    dstAddr : 48;
    srcAddr : 48;
    etherType : 16;
  }
}

header ethernet_t ethernet;

header_type ipv4_t {
  fields {
    version : 4;
    ihl : 4;
    diffserv : 8;
    totalLen : 16;
    identification : 16;
    flags : 3;
    fragOffset : 13;
    ttl : 8;
    protocol : 8;
    hdrChecksum : 16;
    srcAddr : 32;
    dstAddr : 32;
  }
}

header ipv4_t ipv4;

field_list ipv4_checksum_list {
  ipv4.version;
  ipv4.ihl;
  ipv4.diffserv;
  ipv4.totalLen;
  ipv4.identification;
  ipv4.flags;
  ipv4.fragOffset;
  ipv4.ttl;
  ipv4.protocol;
  ipv4.srcAddr;
  ipv4.dstAddr;
}

field_list_calculation ipv4_checksum {
  input {
    ipv4_checksum_list;
  }
  algorithm : csum16;
  output_width : 16;
}

calculated_field ipv4.hdrChecksum  {
  verify ipv4_checksum;
  update ipv4_checksum;
}

#endif // __HEADER_H__
