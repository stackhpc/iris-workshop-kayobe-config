===========================================================
Kayobe Configuration for IRIS Scientific OpenStack Workshop
===========================================================

This repository provides configuration for the `Kayobe
<https://kayobe.readthedocs.io/en/latest>`__ project. It is based on the
configuration provided by the `kayobe-config
<https://git.openstack.org/cgit/openstack/kayobe-config>`__ repository, and
provides a set of configuration suitable for a workshop on Scientific
OpenStack.

Requirements
============

The configuration includes:

* 1 controller (localhost)

This should be a bare metal node or VM running CentOS 7, with the following
minimum requirements:

* 16GB RAM
* 20GB disk

Assumes that a Docker registry mirror is available at ``registry.local:5000``,
and a web proxy is available at ``registry.local:3128``.

Usage
=====

.. code-block:: console

   # Clone Kayobe.
   git clone https://git.openstack.org/openstack/kayobe.git
   cd kayobe

   # Clone this Kayobe configuration.
   mkdir -p config/src
   cd config/src/
   git clone https://github.com/stackhpc/iris-workshop-kayobe-config.git -b scenario1 kayobe-config

   ./kayobe-config/configure-local-networking.sh

   # Install kayobe.
   cd ~/kayobe
   ./dev/install.sh
   source dev/environment-setup.sh

Now continue from ‘kayobe control host bootstrap’ in the `Kayobe development
environment documentation
<https://kayobe.readthedocs.io/en/latest/development/manual.html#manual-installation>`__.

At this point it should be possible to access the Horizon GUI via the seed
hypervisor's floating IP address, using port 80 (achieved through port
forwarding).

Note that when accessing the VNC console of an instance via Horizon, you will
be sent to the internal IP address of the controller, 192.168.33.2, which will
fail. Replace this with the floating IP of the seed hypervisor VM.

The following script will register some resources in OpenStack to enable
booting up a tenant VM.

.. code-block:: console

   source config/src/kayobe-config/etc/kolla/public-openrc.sh
   ./config/src/kayobe-config/init-runonce.sh

Following the instructions displayed by the above script, boot a VM.  You'll
need to have activated the ~/os-venv virtual environment.

.. code-block:: console

   source ~/os-venv/bin/activate
   openstack server create --image cirros --flavor m1.tiny --key-name mykey --network demo-net demo1

   # TODO: SSH access to VM

References
==========

* Kayobe documentation: https://kayobe.readthedocs.io/en/latest/
* Source: https://git.openstack.org/cgit/openstack/kayobe-config-dev
* Bugs: https://storyboard.openstack.org/#!/project/openstack/kayobe-config-dev
* IRC: #openstack-kayobe
