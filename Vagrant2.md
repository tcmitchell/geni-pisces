# Recreating the PISCES vagrant demo

## Allocate a hardware node

My node was a `m510` at Utah CloudLab running Ubuntu 14.04.
Here is the manifest:

```
<?xml version="1.0"?>
<rspec xmlns="http://www.geni.net/resources/rspec/3" xmlns:emulab="http://www.protogeni.net/resources/rspec/ext/emulab/1" xmlns:jacks="http://www.protogeni.net/resources/rspec/ext/jacks/1" xmlns:tour="http://www.protogeni.net/resources/rspec/ext/apt-tour/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" expires="2017-03-24T21:08:27Z" type="manifest" xsi:schemaLocation="http://www.geni.net/resources/rspec/3    http://www.geni.net/resources/rspec/3/manifest.xsd">
  <node xmlns:emulab="http://www.protogeni.net/resources/rspec/ext/emulab/1" client_id="node-0" component_id="urn:publicid:IDN+utah.cloudlab.us+node+ms1041" component_manager_id="urn:publicid:IDN+utah.cloudlab.us+authority+cm" exclusive="true" sliver_id="urn:publicid:IDN+utah.cloudlab.us+sliver+111922">
    <icon xmlns="http://www.protogeni.net/resources/rspec/ext/jacks/1" url="https://portal.geni.net/images/RawPC-IG.svg"/>
    <sliver_type name="raw-pc">
      <disk_image name="urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU14-64-X86"/>
    </sliver_type>
    <hardware_type name="pc"/>
    <services>
      <login authentication="ssh-keys" hostname="ms1041.utah.cloudlab.us" port="22" username="tmitchel"/>
      <emulab:console server="boss.utah.cloudlab.us"/>
    </services>
    <emulab:vnode hardware_type="m510" name="ms1041"/>
    <host ipv4="128.110.153.194" name="node-0.pisces.tcm-test-PG0.utah.cloudlab.us"/>
  </node>
  <rs:site_info xmlns:rs="http://www.protogeni.net/resources/rspec/ext/site-info/1">
    <rs:location country="US" latitude="40.750714" longitude="-111.893288"/>
  </rs:site_info>
</rspec>
```

## Update the OS

```
sudo apt-get update
sudo apt-get upgrade
```

## Install VirtualBox

Follow the instructions that VirtualBox provides:

    https://www.virtualbox.org/wiki/Linux_Downloads

For me this involved adding the following line to the end of
`/etc/apt/sources.list`:

```
deb http://download.virtualbox.org/virtualbox/debian xenial contrib
```

Add the signing key:

```
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
```

Then make the OS aware of the repo contents:

```
sudo apt-get update
```

And finally install VirtualBox:

```
sudo apt-get install virtualbox-5.1
```

## Install Vagrant

The vagrant included with Ubuntu 16.04 is too old for VirtualBox 5.1.
Install vagrant by downloading it. Go to
https://www.vagrantup.com/downloads.html and download the latest release
for Debian 64-bit.

After using wget to fetch the vagrant deb file I had to rename it to
remove the trailing http argument that started with "?\_ga=..."

Install the file as follows:

```
sudo dpkg -i vagrant_1.9.3_x86_64.deb
sudo apt-get install -f
```

Note: I first installed vagrant via apt-get, and that installed a lot of
dependencies. I then uninstalled vagrant and installed the downloaded
package file with the above instructions. It now says there are a lot
of packages that are no longer required. It's possible just doing the above
won't handle dependencies properly. If it does handle the dependencies
properly, please update this note or remove it.

## Install the PISCES vagrant box

Follow the instructions at https://github.com/P4-vSwitch/vagrant
to install.

## Success

I was able to run the PISCES "Simple Layer-2 Switch" demonstration.
This involves three VMs:

* switch (runs OVS)
* generator (sends packets)
* receiver (receives packets)
