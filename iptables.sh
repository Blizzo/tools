#!/usr/bin/env bash
#set path of iptables
path=/sbin

#getting to drop all previous rules
$path/iptables -F

# Drop all IPv6 stuff
$path/ip6tables -A INPUT -j DROP
$path/ip6tables -A OUTPUT -j DROP

# Accept in/out from loopback
$path/iptables -A INPUT -i lo -j ACCEPT
$path/iptables -A OUTPUT -o lo -j ACCEPT

# Allow icmp request/reply from and to host
$path/iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
$path/iptables -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT
$path/iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
$path/iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT

# Allow established TCP connections to re-enter
$path/iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT

# Allow DNS and #DHCP
$path/iptables -A INPUT -p udp --sport 53 -j ACCEPT
$path/iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# Allow HTTP and HTTPS
$path/iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# Log firewall hits
$path/iptables -A INPUT -j LOG --log-level 7 --log-prefix "** outv4 ** "
$path/iptables -A OUTPUT -j LOG --log-level 7 --log-prefix "** inv4 ** "
$path/ip6tables -A INPUT -j LOG --log-level 7 --log-prefix "** IPv6 DROPPED INPUT ** "
$path/ip6tables -A OUTPUT -j LOG --log-level 7 --log-prefix "** IPv6 DROPPED OUTPUT ** "

# Drop all other stuff
$path/iptables -A INPUT -j DROP
$path/iptables -A OUTPUT -j DROP



