#!/usr/bin/env bash
#set path of iptables
path=/sbin

#drop all previous rules
$path/iptables -F

#block typical bad stuff
$path/iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP #null packets
$path/iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP #syn-flood packets
$path/iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP #XMAS packets (recon)
$path/iptables -A INPUT -m state --state INVALID -j DROP #invalid packets

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
#$path/iptables -A INPUT -p udp -m multiport --sports 67,68 -j ACCEPT
#$path/iptables -A OUTPUT -p udp -m multiport --dports 67,68 -j ACCEPT

# Allow HTTP and HTTPS out
$path/iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

#Allow web server traffic in
$path/iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

#allow ssh in and out
$path/iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
$path/iptables -A OUTPUT -p tcp -m tcp --dport 22 -j ACCEPT

#allow FTP server traffic - not sure if this works
$path/iptables -A INPUT -p tcp -m tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT #initial connection
$path/iptables -A OUTPUT -p tcp -m tcp --sport 21 -m state --state NEW,ESTABLISHED -j ACCEPT #initial connection
$path/iptables -A INPUT -p tcp -m tcp --dport 20 -m state --state NEW,ESTABLISHED -j ACCEPT #active mode
$path/iptables -A OUTPUT -p tcp -m tcp --sport 20 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT #active mode
$path/iptables -A INPUT -p tcp -m tcp --sport 1024:65535 --dport 1024:65535 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT #passive
$path/iptables -A OUTPUT -p tcp -m tcp --sport 1024:65535 --dport 1024:65535 -m state --state NEW,ESTABLISHED -j ACCEPT #passive


#iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
#iptables -A OUTPUT -p tcp -m tcp --dport 25 -j ACCEPT

# Log firewall hits
$path/iptables -I INPUT -j LOG --log-level 7 --log-prefix "INv4 "
$path/iptables -I OUTPUT -j LOG --log-level 7 --log-prefix "OUTv4 "
$path/ip6tables -I INPUT -j LOG --log-level 7 --log-prefix "INv6 "
$path/ip6tables -I OUTPUT -j LOG --log-level 7 --log-prefix "OUTv6 "

# Drop all other stuff
$path/iptables -A INPUT -j DROP
$path/iptables -A OUTPUT -j DROP
$path/ip6tables -A INPUT -j DROP
$path/ip6tables -A OUTPUT -j DROP


