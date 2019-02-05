#!/bin/bash

set -e

# This should be run on the seed hypervisor.

# Configure local networking.
sudo ip l add braio type bridge
sudo ip l set braio up
sudo ip a add 192.168.33.4/24 dev braio
sudo iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE
sudo sysctl -w net.ipv4.conf.all.forwarding=1
