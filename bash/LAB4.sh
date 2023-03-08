#!/bin/bash
#

# TASK 1: Accept options on the command line for verbose mode and an interface name - must use the while loop and case command as shown in the lesson - getopts not acceptable for this task
#         If the user includes the option -v on the command line, set the variable $verbose to contain the string "yes"
verboss=$(echo "$@" |grep -e "-v")
if [[ $verboss = *"-v"* ]];
then 
verbose="yes"; 
echo "Verboss is set to $verbose because of $verboss is selected"
fi
#            e.g. network-config-expanded.sh -v
#         If the user includes one and only one string on the command line without any option letter in front of it, only show information for that interface
#            e.g. network-config-expanded.sh ens34
#         Your script must allow the user to specify both verbose mode and an interface name if they want

function ifinfo1 {
# i=0
len=1
ifinfomul1
exit 0
}

# TASK 2: Dynamically identify the list of interface names for the computer running the script, and use a for loop to generate the report for every interface except loopback - do not include loopback network information in your output


################
# Data Gathering
################
# the first part is run once to get information about the host
# grep is used to filter ip command output so we don't have extra junk in our output
# stream editing with sed and awk are used to extract only the data we want displayed

#####
# Once per host report
#####
[ "$verbose" = "yes" ] && echo "Gathering host information"
# we use the hostname command to get our system name and main ip address
my_hostname="$(hostname) / $(hostname -I)"

[ "$verbose" = "yes" ] && echo "Identifying default route"
# the default route can be found in the route table normally
# the router name is obtained with getent
default_router_address=$(ip r s default| awk '{print $3}')
default_router_name=$(getent hosts $default_router_address|awk '{print $2}')

[ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
# finding external information relies on curl being installed and relies on live internet connection
external_address=$(curl -s icanhazip.com)
external_name=$(getent hosts $external_address | awk '{print $2}')

cat <<EOF

System Identification Summary
=============================
Hostname      : $my_hostname
Default Router: $default_router_address
Router Name   : $default_router_name
External IP   : $external_address
External Name : $external_name

EOF

#####
# End of Once per host report
#####


# the second part of the output generates a per-interface report
# the task is to change this from something that runs once using a fixed value for the interface name to
#   a dynamic list obtained by parsing the interface names out of a network info command like "ip"
#   and using a loop to run this info gathering section for every interface found

# the default version uses a fixed name and puts it in a variable

readarray -t interface < <(lshw -class network | awk '/logical name:/{print $3}')
len=${#interface[*]}

function ifinfomul1 {
#lshw -class network | awk '/logical name:/{print $3}' | grep -v "WARNING: you should run this program as super-user." | grep -v "WARNING: output may be incomplete or inaccurate, you should run this program as super-user."
###-----------declare -a interface=$(lshw -class network | awk '/logical name:/{print $3}')

i=0
while [ $i -lt $len ]
do
#####
# Per-interface report
#####

# define the interface being summarized
if [[ ${interface[$i]} = loo* ]] ; then continue ; fi # loopback
if [[ ${interface[$i]} = lo* ]] ; then continue ; fi # local host
if [[ ${interface[$i]} = WARNING* ]] ; then continue ; fi # extra warning added to array
interface="echo ${interface[$i]}"

[ "$verbose" = "yes" ] && echo "Reporting on interface(s): ${interface[$i]}"

[ "$verbose" = "yes" ] && echo "Getting IPV4 address and name for interface ${interface[$i]}"
# Find an address and hostname for the interface being summarized
# we are assuming there is only one IPV4 address assigned to this interface
ipv4_address=$(ip a s ${interface[$i]}|awk -F '[/ ]+' '/inet /{print $3}')
ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')

[ "$verbose" = "yes" ] && echo "Getting IPV4 network block info and name for interface ${interface[$i]}"
# Identify the network number for this interface and its name if it has one
# Some organizations have enough networks that it makes sense to name them just like how we name hosts
# To ensure your network numbers have names, add them to your /etc/networks file, one network to a line, as   networkname networknumber
#   e.g. grep -q mynetworknumber /etc/networks || (echo 'JatinNet 192.168.139.0' |sudo tee -a /etc/networks)
network_address=$(ip route list dev $interface scope link|cut -d ' ' -f 1)
network_number=$(cut -d / -f 1 <<<"$network_address")
network_name=$(getent networks $network_number|awk '{print $1}')

# not working if [[ $network_name = link* ]] ; then continue ; fi # if want to remove link local iface

cat <<EOF

Interface ${interface[$i]}:
===============
Address         : $ipv4_address
Name            : $ipv4_hostname
Network Address : $network_address
Network Name    : $network_name

EOF

i=$((i+1))
#####
# End of per-interface report
#####
done
}

while [[ $# -gt 0 ]]
do
	case $1 in
		-v | --verbose )
		verbose="yes"
		;;
		*)
		interface[0]=$1
        ifinfo1
        ;;
	esac
	shift
done
ifinfomul1
# if [[ $# -eq 0 ]]; then
#     echo "No arguments provided"
# 	echo "Running a full report:"
# 	ifinfomul1
#     exit 1
# fi
