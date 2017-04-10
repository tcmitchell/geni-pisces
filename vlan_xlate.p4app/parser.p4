parser start {
  return parse_ethernet;
}

parser parse_ethernet {
  extract(ethernet);
  return select(latest.etherType) {
    0x800: parse_ipv4;
    default: ingress;
  }
}

parser parse_ipv4 {
  extract(ipv4);
  return ingress;
}
