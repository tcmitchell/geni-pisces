## Allocate topology

PISCES requires Ubuntu 14.04 at this time. Please be sure you are using
an Ubuntu 14.04 image in your request RSpec. (I forget what the dependency
really is.)

See the [sample request rspec](request-rspec.xml). Each RSpec must be
hardwired to a specific bare metal node. There are three items that
need to be populated with actual values in the
[sample request rspec](request-rspec.xml).

| Placeholder                     | Description |
| -----------                     | ----------- |
| INSERT PC COMPONENT ID          | component id of the bare metal node |
| INSERT INTERFACE COMPONENT ID 1 | component id of a network interface on the node |
| INSERT INTERFACE COMPONENT ID 2 | component id of a 2nd network interface on the node |

## Update OS

Update the OS. See [Update Notes]() below for help.

```shell
sudo apt-get update
sudo apt-get upgrade -y

```

After the update is complete, reboot the host:

```shell
sudo reboot

```

### Update Notes

1. Always "keep your currently-installed version" when prompted
2. Updating GRUB:
  i. keep the local version currently installed; Ok
  ii. Ok (previously installed on disk no longer present)
  iii. Select NO devices; Ok
  iv. Continue without installing GRUB?  Yes

## Use ansible to configure the PISCES host

1. Install ansible

    ```
    sudo apt-get install -y ansible

    ```

2. Clone geni-pisces repository

    ```
    git clone https://github.com/tcmitchell/geni-pisces

    ```

3. Install latest ansible

    ```
    cd geni-pisces
    ansible-playbook -i localhost, -c local ansible/ansible.yml

    ```

4. Install PISCES dependencies

   ```
   ansible-playbook -i localhost, -c local ansible/pisces.yml

   ```

##



# Future Work

1. Add ARP replies so ARP doesn't have to be hardcoded
2. Can the VLAN example use a single data plane interface?
3. Can the example run on Ubuntu 16? If not, why not?
4. Develop a custom protocol example
