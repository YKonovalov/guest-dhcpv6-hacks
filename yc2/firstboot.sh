#!/bin/sh
# options -efu do not work in cygwin. Nevermind :)
# This script works in Linux and Cygwin
#

DIR="${0%/*}"
. "$DIR/yc2-sh-functions"
. "$DIR/yc2-platform-functions"
. "$DIR/yc2-ec2-functions"

cleanup_history

IAMTHEHOST=$(hostname)
DEF_FQDN="newborn"

DEF_DOMAIN=""
DHCPv6="$(grep 'option fqdn.domainname' /var/db/dhclient6.leases|awk -F\" '{print $2; exit}')"
DHCPv6=${DHCPv6#.}
if [ -n "$DHCPv6" ]; then
	DEF_DOMAIN=$DHCPv6
else
	DHCPv4="$(grep 'option domain-name ' /var/db/dhclient.leases|awk -F\" '{print $2; exit}'|awk '{print $1}')"
	if [ -n "$DHCPv4" ]; then
		DEF_DOMAIN=$DHCPv4
	fi
fi
export DEF_DOMAIN

# Set instance name as a hostname
dolog "Customization started with a default hostname: $IAMTHEHOST"
ec2_instance=$(set_ec2_hostname)
dolog "Got $ec2_instance as a best guess for instance name"

# Get ssh key
instance_get_key
do_resize_root

