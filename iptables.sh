#getting to drop all traffic
iptable -F

# Drop all IPv6 stuff
ip6tables -A INPUT -j DROP
ip6tables -A OUTPUT -j DROP

# Accept in/out from loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow icmp request/reply from and to host
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT

# Allow established TCP connections to re-enter
iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT

# Allow DNS and #DHCP
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# Allow HTTP and HTTPS
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# Log firewall hits
iptables -A INPUT -j LOG --log-level 7 --log-prefix "** outv4 ** "
iptables -A OUTPUT -j LOG --log-level 7 --log-prefix "** inv4 ** "
ip6tables -A INPUT -j LOG --log-level 7 --log-prefix "** IPv6 DROPPED INPUT ** "
ip6tables -A OUTPUT -j LOG --log-level 7 --log-prefix "** IPv6 DROPPED OUTPUT ** "

# Drop all other stuff
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP



