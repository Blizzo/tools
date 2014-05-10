#!/usr/bin/env bash
#set path of iptables
path=/sbin
shitboxIP=10.0.0.0
scoremaster=10.0.0.0

#drop all previous rules
$path/iptables -F

#VOIP - needed on electrode for asterisk/voip server!
# SIP on UDP port 5060. Other SIP servers may need TCP port 5060 as well
#$path/iptables -A INPUT -p udp -m udp --dport 5060 -j ACCEPT
#$path/iptables -A INPUT -p udp -m udp --dport 4569 -j ACCEPT # IAX2- the IAX protocol
#$path/iptables -A INPUT -p udp -m udp --dport 5036 -j ACCEPT # IAX - most have switched to IAX v2, or ought to
 # RTP - the media stream
#$path/iptables -A INPUT -p udp -m udp --dport 10000:20000 -j ACCEPT # (related to the port range in /etc/asterisk/rtp.conf)
#$path/iptables -A INPUT -p udp -m udp --dport 2727 -j ACCEPT # MGCP - if you use media gateway control protocol in your configuration

# Allow HTTP and HTTPS in and out
$path/iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
$path/iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

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

#allow ssh in and out; only if you have ssh!
#$path/iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
#$path/iptables -A OUTPUT -p tcp -m tcp --dport 22 -j ACCEPT

#allow FTP server traffic; only for ftp servers!
$path/iptables -A INPUT -p tcp -m tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT #initial connection
$path/iptables -A OUTPUT -p tcp -m tcp --sport 21 -m state --state NEW,ESTABLISHED -j ACCEPT #initial connection
$path/iptables -A INPUT -p tcp -m tcp --dport 20 -m state --state NEW,ESTABLISHED -j ACCEPT #active mode
$path/iptables -A OUTPUT -p tcp -m tcp --sport 20 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT #active mode
$path/iptables -A INPUT -p tcp -m tcp --sport 1024:65535 --dport 1024:65535 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT #passive
$path/iptables -A OUTPUT -p tcp -m tcp --sport 1024:65535 --dport 1024:65535 -m state --state NEW,ESTABLISHED -j ACCEPT #passive

#smtp in/out rules; only for smtp servers!
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


# INSTATE THESE RULES ON HOST TO PROTECT
# NOTE: vsftpd needs pasv_promiscuous=yes for "fake" ftp

# echo "1" > /proc/sys/net/ipv4/ip_forward
# $path/iptables -D INPUT -j DROP
# $path/iptables -D OUTPUT -j DROP
# $path/iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination $shitboxIP #Make all traffic go to the playground
# $path/iptables -t nat -A POSTROUTING -d $shitboxIP -p tcp -j MASQUERADE
# $path/iptables -t nat -I PREROUTING -p tcp -s $scoremaster -j ACCEPT #Accept all traffic from the scorebox

# $path/iptables -t nat -A PREROUTING -p udp -j DNAT --to-destination $shitboxIP #Make all traffic go to the playground
# $path/iptables -t nat -A POSTROUTING -d $shitboxIP -p udp -j MASQUERADE
# $path/iptables -t nat -I PREROUTING -p udp -s $scoremaster -j ACCEPT #Accept all traffic from the scorebox

#$path/iptables -I INPUT -d $shitboxIP -j ACCEPT
#$path/iptables -I FORWARD -d $shitboxIP -j ACCEPT
#$path/iptables -I OUTPUT -d $shitboxIP -j ACCEPT
#$path/iptables -I INPUT -s $shitboxIP -j ACCEPT
#$path/iptables -I FORWARD -s $shitboxIP -j ACCEPT
#$path/iptables -I OUTPUT -s $shitboxIP -j ACCEPT

