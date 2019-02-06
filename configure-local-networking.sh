#!/bin/bash

set -e

# This should be run on the controller.

# IP addresses on the all-in-one Kayobe cloud network.
# These IP addresses map to those statically configured in
# etc/kayobe/network-allocation.yml and etc/kayobe/networks.yml.
controller_vip=192.168.33.2
controller_ip=192.168.33.3

# Private IP address by which the controller is accessible in the cloud hosting
# the VM.
controller_private_ip=$(ip a show dev eth0 | grep 'inet ' | awk '{ print $2 }' | sed 's/\/.*//g')

# Forward the following ports to the controller.
# 80: Horizon
# 6080: VNC console
forwarded_ports="80 6080"

# IP of the controller on the OpenStack 'public' network created by init-runonce.sh.
public_ip="10.0.2.1"

# Configure local networking.
if ! sudo ip l show breth1 2>&1 >/dev/null; then
  # Add a bridge 'breth1' for the Kayobe all-in-one cloud network.
  sudo ip l add breth1 type bridge
  sudo ip l set breth1 up
  sudo ip a add $controller_ip/24 dev breth1
fi

# Configure IP routing and NAT to allow deployed instances to route to the
# outside world.
sudo iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE
sudo sysctl -w net.ipv4.conf.all.forwarding=1

# Configure port forwarding from the hypervisor to the Horizon GUI on the
# controller.
sudo iptables -A FORWARD -i eth0 -o breth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i breth1 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
for port in $forwarded_ports; do
  # Allow new connections.
  sudo iptables -A FORWARD -i eth0 -o breth1 -p tcp --syn --dport $port -m conntrack --ctstate NEW -j ACCEPT
  # Destination NAT.
  sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $port -j DNAT --to-destination $controller_vip
  # Source NAT.
  sudo iptables -t nat -A POSTROUTING -o breth1 -p tcp --dport $port -d $controller_vip -j SNAT --to-source $controller_private_ip
done

# Configure an IP on the 'public' network to allow access to/from the cloud.
sudo ip a add $public_ip/24 dev breth1

echo
echo "NOTE: The network configuration applied by this script is not"
echo "persistent across reboots."
echo "If you reboot the system, please re-run this script."
