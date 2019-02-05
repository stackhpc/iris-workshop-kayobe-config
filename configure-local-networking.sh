#!/bin/bash

set -e

# This should be run on the seed hypervisor.

# IP addresses on the all-in-one Kayobe cloud network.
# These IP addresses map to those statically configured in
# etc/kayobe/network-allocation.yml.
controller_ip=192.168.33.3
seed_hv_ip=192.168.33.4
seed_vm_ip=192.168.33.5

# Private IP address by which the seed hypervisor is accessible in the cloud
# hosting the VM.
seed_hv_private_ip=$(ip a show dev eth0 | grep 'inet ' | awk '{ print $2 }' | sed 's/\/.*//g')

# Configure local networking.
# Add a bridge 'braio' for the Kayobe all-in-one cloud network.
sudo ip l add braio type bridge
sudo ip l set braio up
sudo ip a add $seed_hv_ip/24 dev braio

# Configure IP routing and NAT to allow the seed VM and overcloud hosts to
# route via this route to the outside world.
sudo iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE
sudo sysctl -w net.ipv4.conf.all.forwarding=1

# Configure port forwarding from the hypervisor to the Horizon GUI on the
# controller.
sudo iptables -A FORWARD -i eth0 -o braio -p tcp --syn --dport 80 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o braio -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i braio -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination $controller_ip
sudo iptables -t nat -A POSTROUTING -o braio -p tcp --dport 80 -d $controller_ip -j SNAT --to-source $seed_hv_private_ip
