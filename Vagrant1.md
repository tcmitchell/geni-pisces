# Recreating the PISCES vagrant demo

Note: This attempt ended in [failure](#failure).

## Allocate a hardware node

My node was a pc300 at Emulab running Ubuntu 16.04.

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
wget https://www.virtualbox.org/download/oracle_vbox_2016.asc
sudo apt-key add oracle_vbox_2016.asc
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


## Failure

_This did not work on a pc3000._

Here's the transcript:

```
$ vagrant up --provider=virtualbox
Bringing machine 'switch' up with 'virtualbox' provider...
Bringing machine 'generator' up with 'virtualbox' provider...
Bringing machine 'receiver' up with 'virtualbox' provider...
==> switch: Importing base box 'pisces-ubuntu-trusty64'...
==> switch: Matching MAC address for NAT networking...
==> switch: Setting the name of the VM: vagrant_switch_1490297175485_87278
==> switch: Clearing any previously set network interfaces...
==> switch: Preparing network interfaces based on configuration...
    switch: Adapter 1: nat
    switch: Adapter 2: intnet
    switch: Adapter 3: intnet
    switch: Adapter 4: hostonly
==> switch: Forwarding ports...
    switch: 22 (guest) => 2222 (host) (adapter 1)
==> switch: Running 'pre-boot' VM customizations...
==> switch: Booting VM...
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["startvm", "4f633f7f-6920-45d2-b443-eaa328867a51", "--type", "headless"]

Stderr: VBoxManage: error: VT-x is not available (VERR_VMX_NO_VMX)
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component ConsoleWrap, interface IConsole
```

I found a post that suggested the following:

```
sudo apt-get install cpu-checker

sudo kvm-ok
```

That revealed:

```
$ sudo kvm-ok
INFO: Your CPU does not support KVM extensions
KVM acceleration can NOT be used
```

Perhaps the pc3000 is too old, and perhaps that's why it was available
in the first place.
