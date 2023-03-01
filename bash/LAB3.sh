#!/bin/bash
#Command to install lxd
if which lxc;then
 echo "lxd exists in this operating system"
else
 echo "lxd is not installed in this operating system installing lxd"
sudo snap install lxd
fi
#Task2
if ! ip a show lxdbr0; then
echo "lxdbr0 interface does not exist"
# Initialize LXD with --auto flag
sudo lxd init --auto
else
echo "LXDBR interface exist"
fi
#Command to launch a container
if ! lxc info COMP2101-S22; then
echo "Container does not exist"
# Launch a new container running Ubuntu 20.04 server
lxc launch images:ubuntu/20.04 COMP2101-S22
else 
echo "Container already exists"
fi
#Command to add or update the entry
if ! grep -q "COMP2101-S22" /etc/hosts; then
echo "$IP COMP2101-S22" | sudo gedit /etc/hosts
else
echo "updated"
fi
#Command to install Apache2 in the container
lxc exec COMP2101-S22 -- apt-get install apache2
#Command to retrieve

curl http://COMP2101-S22

echo "The webpage is successfully retrieved"
