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

* 1 seed hypervisor (localhost)
* 1 seed
* 1 controller
* 1 compute node

The latter three hosts are run as VMs on the seed hypervisor.  This should be
a bare metal node or VM running CentOS 7, with the following minimum
requirements:

* 32GB RAM
* 40GB disk

Usage
=====

.. code-block:: console

   # Clone Kayobe.
   git clone https://git.openstack.org/openstack/kayobe.git
   cd kayobe
   git fetch https://git.openstack.org/openstack/kayobe refs/changes/74/634274/1 && git checkout FETCH_HEAD

   # Clone this Kayobe configuration.
   mkdir -p config/src
   cd config/src/
   git clone https://github.com/stackhpc/iris-workshop-kayobe-config.git kayobe-config

   ./kayobe-config/configure-local-networking.sh

   # Install kayobe.
   cd ~/kayobe
   ./dev/install.sh

   # Deploy hypervisor services.
   ./dev/seed-hypervisor-deploy.sh

   # Deploy a seed VM.
   ./dev/seed-deploy.sh

   # Clone the Tenks repository, deploy some VMs for the controller and compute node.
   git clone https://git.openstack.org/openstack/tenks.git
   # NOTE: Make sure to use ./tenks, since just ‘tenks’ will install via PyPI.
   export TENKS_CONFIG_PATH=config/src/kayobe-config/tenks.yml
   ./dev/tenks-deploy.sh ./tenks

   # Activate the Kayobe environment, to allow running commands directly.
   source dev/environment-setup.sh

   # Inspect and provision the overcloud hardware:
   kayobe overcloud inventory discover
   kayobe overcloud hardware inspect
   kayobe overcloud provision

   # Deploy the control plane:
   # (following https://kayobe.readthedocs.io/en/latest/deployment.html#id3)
   kayobe overcloud host configure
   kayobe overcloud container image pull
   kayobe overcloud service deploy
   source config/src/kayobe-config/etc/kolla/public-openrc.sh
   kayobe overcloud post configure

   TODO: register resources, create a VM.

References
==========

* Kayobe documentation: https://kayobe.readthedocs.io/en/latest/
* Source: https://git.openstack.org/cgit/openstack/kayobe-config-dev
* Bugs: https://storyboard.openstack.org/#!/project/openstack/kayobe-config-dev
* IRC: #openstack-kayobe
