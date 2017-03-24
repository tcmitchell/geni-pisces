Running on Emulab, we may be able to use a d430 which explicitly has
VT-x enabled. See https://wiki.emulab.net/Emulab/wiki/UtahHardware
for hardware details.

Here's my manifest:

```
<?xml version="1.0"?>
<rspec xmlns="http://www.geni.net/resources/rspec/3" xmlns:emulab="http://www.protogeni.net/resources/rspec/ext/emulab/1" xmlns:jacks="http://www.protogeni.net/resources/rspec/ext/jacks/1" xmlns:tour="http://www.protogeni.net/resources/rspec/ext/apt-tour/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" expires="2017-03-24T23:54:35Z" type="manifest" xsi:schemaLocation="http://www.geni.net/resources/rspec/3    http://www.geni.net/resources/rspec/3/manifest.xsd">
  <node xmlns:emulab="http://www.protogeni.net/resources/rspec/ext/emulab/1" client_id="node-2" component_id="urn:publicid:IDN+emulab.net+node+pc749" component_manager_id="urn:publicid:IDN+emulab.net+authority+cm" exclusive="true" sliver_id="urn:publicid:IDN+emulab.net+sliver+332792">
    <icon xmlns="http://www.protogeni.net/resources/rspec/ext/jacks/1" url="https://portal.geni.net/images/RawPC-IG.svg"/>
    <sliver_type name="raw-pc">
      <disk_image name="urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU16-64-STD"/>
    </sliver_type>
    <hardware_type name="d430"/>
    <services>
      <login authentication="ssh-keys" hostname="pc749.emulab.net" port="22" username="tmitchel"/>
      <emulab:console server="boss.emulab.net"/>
    </services>
    <emulab:vnode hardware_type="d430" name="pc749"/>
    <host ipv4="155.98.36.49" name="node-2.pisces.tcm-test-PG0.emulab.net"/>
  </node>
  <rs:site_info xmlns:rs="http://www.protogeni.net/resources/rspec/ext/site-info/1">
    <rs:location country="US" latitude="40.768652" longitude="-111.84581"/>
  </rs:site_info>
</rspec>
```


Here's a possible request RSpec for a PISCES topology with two VMs and
one bare metal node:

```
<rspec xmlns="http://www.geni.net/resources/rspec/3" xmlns:emulab="http://www.protogeni.net/resources/rspec/ext/emulab/1" xmlns:tour="http://www.protogeni.net/resources/rspec/ext/apt-tour/1" xmlns:jacks="http://www.protogeni.net/resources/rspec/ext/jacks/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.geni.net/resources/rspec/3    http://www.geni.net/resources/rspec/3/request.xsd" type="request">
  <node xmlns="http://www.geni.net/resources/rspec/3" client_id="switch" component_manager_id="urn:publicid:IDN+emulab.net+authority+cm">
    <icon xmlns="http://www.protogeni.net/resources/rspec/ext/jacks/1" url="https://portal.geni.net/images/RawPC-IG.svg"/>
    <sliver_type xmlns="http://www.geni.net/resources/rspec/3" name="raw-pc">
      <disk_image xmlns="http://www.geni.net/resources/rspec/3" name="urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU16-64-STD"/>
    </sliver_type>
    <hardware_type xmlns="http://www.geni.net/resources/rspec/3" name="d430"/>
    <services xmlns="http://www.geni.net/resources/rspec/3"/>
    <interface xmlns="http://www.geni.net/resources/rspec/3" client_id="interface-0"/>
    <interface xmlns="http://www.geni.net/resources/rspec/3" client_id="interface-3"/>
  </node>
  <node xmlns="http://www.geni.net/resources/rspec/3" client_id="receiver" component_manager_id="urn:publicid:IDN+emulab.net+authority+cm">
    <icon xmlns="http://www.protogeni.net/resources/rspec/ext/jacks/1" url="https://portal.geni.net/images/Xen-VM.svg"/>
    <sliver_type xmlns="http://www.geni.net/resources/rspec/3" name="emulab-xen">
      <disk_image xmlns="http://www.geni.net/resources/rspec/3" name="urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU14-64-STD"/>
    </sliver_type>
    <services xmlns="http://www.geni.net/resources/rspec/3"/>
    <interface xmlns="http://www.geni.net/resources/rspec/3" client_id="interface-1"/>
  </node>
  <node xmlns="http://www.geni.net/resources/rspec/3" client_id="generator" component_manager_id="urn:publicid:IDN+emulab.net+authority+cm">
    <icon xmlns="http://www.protogeni.net/resources/rspec/ext/jacks/1" url="https://portal.geni.net/images/Xen-VM.svg"/>
    <sliver_type xmlns="http://www.geni.net/resources/rspec/3" name="emulab-xen">
      <disk_image xmlns="http://www.geni.net/resources/rspec/3" name="urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU14-64-STD"/>
    </sliver_type>
    <services xmlns="http://www.geni.net/resources/rspec/3"/>
    <interface xmlns="http://www.geni.net/resources/rspec/3" client_id="interface-2"/>
  </node>
  <link xmlns="http://www.geni.net/resources/rspec/3" client_id="link-0">
    <interface_ref xmlns="http://www.geni.net/resources/rspec/3" client_id="interface-0"/>
    <interface_ref xmlns="http://www.geni.net/resources/rspec/3" client_id="interface-1"/>
    <component_manager xmlns="http://www.geni.net/resources/rspec/3" name="urn:publicid:IDN+emulab.net+authority+cm"/>
  </link>
  <link xmlns="http://www.geni.net/resources/rspec/3" client_id="link-1">
    <interface_ref xmlns="http://www.geni.net/resources/rspec/3" client_id="interface-2"/>
    <interface_ref xmlns="http://www.geni.net/resources/rspec/3" client_id="interface-3"/>
    <component_manager xmlns="http://www.geni.net/resources/rspec/3" name="urn:publicid:IDN+emulab.net+authority+cm"/>
  </link>
</rspec>
```

# Instructions

Follow the script at https://github.com/P4-vSwitch/vagrant/blob/master/setup-switch.sh

Replace `/home/vagrant` with `~/`. We could probably submit a pull
request to make a change such that if a directory is specified,
use that, otherwise default to `/home/vagrant`

## Install Python setuptools

Also, the script needs Python setuptools, so:

```
sudo apt-get install -y python-setuptools
```

## Install Python YAML

And it needs Python YAML:

```
sudo apt-get install python-yaml
```

## Patch DPDK on Ubuntu 16
On Ubuntu 16 dpdk complilation fails with error:

    error: ‘struct pci_dev’ has no member named ‘msi_list’

Here's the patch: http://dpdk.org/dev/patchwork/patch/8370/

# Configure Huge Pages

The last command when configuring huge pages requires root, so do this
instead:

```
sudo sh -c 'echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages'
```
