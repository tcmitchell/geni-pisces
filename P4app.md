# P4app

p4app is a development environment for P4. It supports compiling, testing,
and debugging P4 programs. You can run this environment on a GENI virtual
machine very easily.

## Allocate a GENI VM

Allocate a Xen VM running Ubuntu 16.04 at an InstaGENI site. Ubuntu 16.04
is the default OS image for Xen VMs, so this should be straightforward.
Refer to the GENI documentation if you need help.

## Install p4app

Follow the steps in the [p4app repository](https://github.com/p4lang/p4app).
A brief overview is provided here, but the latest instructions in the
[p4app repository](https://github.com/p4lang/p4app) will be the most
accurate and up to date.

### Install Docker

There is an ansible script to install Docker Community Edition (CE).

* Install ansible

    ```
    sudo apt-get install -y ansible
    ```

* Install docker via ansible

    ```
    cd geni-pisces
    ansible-playbook -i localhost -c local ansible/docker.yml
    ```

The ansible script performs the
[installation instructions](https://docs.docker.com/engine/installation/)
for Docker CE. If you would prefer to do the installation yourself,
Here's how to follow the docker
[installation instructions](https://docs.docker.com/engine/installation/):

* Click on your OS (Ubuntu) in the compatibility table
* Scroll past the EE and OS requirements to "Install Docker"
* Follow the instructions to set up the Docker *stable* repository
* Scroll some more and follow the instructions to install the
  `docker-ce` package
* Verify your installation by running the hello-world image

### Get p4app

```
git clone https://github.com/p4lang/p4app.git
```

### Run p4app

Really, you're just about done.

```
cd p4app
./p4app run examples/simple_router.p4app
```

## Follow the p4app log file

When you ran the simple_router example, p4app printed out commands
to watch the log file and launch the debugger. These commands are
specific to the p4app run and will change each time you launch your
program.

### Tail the log file

In your second terminal window, paste the command that looks like this:

```
docker exec -t -i <DOCKER ID> tail -f /var/log/simple_router.p4.log
```

### Send a ping

Now send a single ping from one host to the other. Watch the log file
scroll by as the ping packet and the reply packet are processed.

At the mininet prompt:

```
h1 ping -c 1 h2
```
