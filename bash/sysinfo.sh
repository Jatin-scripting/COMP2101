#!/bin/bash
echo "Second Script"
#dat1 is a variable which gives us hostname
dat1=$(hostname)
#dat2 is a variable which provide the fully qualified domain name(FQDN)
dat2=$(hostname -f)
#dat3 is to provide the whole information regarding the system and grep will trim the operating system information 
dat3=$(hostnamectl | grep Operating)
#dat4 is variable which provide the ip address of the hostname 
dat4=$(hostname -I)
#dat5 is variable that gives us  system information in which awk is used for only the fourth line and then tail is used for last line
dat5=$(df -h / | awk '{print $4}' | tail -n 1)
cat <<EOF
Report for:$dat1
===============
FQDN:$dat2
Operating System name and version is:$dat3
IP Address:$dat4
Root Filesystem's Free Space:$dat5
===============
EOF
