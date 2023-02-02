#!/bin/bash
echo "Fully qualified domain name is="
hostname
echo "Operating system name and version is="
hostnamectl
echo "IP address of server is="
hostname -I
echo "Space available in the root file system is="
df -h /

