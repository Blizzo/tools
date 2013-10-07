#getting to drop all traffic
iptable -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Drop all IPv6 stuff
ip6tables -A INPUT -j DROP
ip6tables -A OUTPUT -j DROP
