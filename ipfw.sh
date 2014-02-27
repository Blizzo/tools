#!/usr/bin/env bash
#set path of ipfw
path=/sbin

$path/ipfw -q -f flush #flush all existing rules

#loopback stuff
$path/ipfw -q add allow all from any to any via lo0 #allow loopback traffic
$path/ipfw -q add deny ip from any to 127.0.0.0/8 #filter loopback traffic
$path/ipfw -q add deny ip from 127.0.0.0/8 to any #filter loopback traffic

#stateful firewall stuffz. and fragmented packet stuff
$path/ipfw -q add check-state
$path/ipfw -q add deny all from any to any frag # deny fragmented packets

#allow established connections
$path/ipfw -q add allow all from any to any established

#services
$path/ipfw -q add allow tcp from any to any 20 #ftp
$path/ipfw -q add allow tcp from any to any 21 #ftp
$path/ipfw -q add allow tcp from any to any 1024-65535 keep-state #for active ftp
$path/ipfw -q add allow tcp from any to me 22 in keep-state #ssh in
$path/ipfw -q add allow tcp from me to any 22 out keep-state #ssh out
#$path/ipfw -q add allow tcp from any to any 25 #smtp; could add keep-state for more securities
$path/ipfw -q add allow udp from me to any 53 out keep-state #dns
#$path/ipfw -q add allow udp from any 68 to any 67 out keep-state #dhcp
#$path/ipfw -q add allow udp from any 67 to any 68 in keep-state #dhcp
$path/ipfw -q add allow tcp from any to any 80 #http
$path/ipfw -q add allow tcp from any to any 443 #https

#normal stuff, allow good in, keep bad out
$path/ipfw -q add allow icmp from any to any icmptype 0,8 #allow ping echo request/reply only
$path/ipfw -q add deny ip from me to me in keep-state #stop spoof/smurf attacks
$path/ipfw -q add deny tcp from any to any setup in keep-state #external setup requests
$path/ipfw -q add deny tcp from any to any 0 in setup keep-state #limit OS detection
$path/ipfw -q add deny udp from any to any 0 in keep-state #limit OS detection

#block the rest
$path/ipfw -q add deny ip6 from  any to any #block all ipv6
$path/ipfw -q add deny log all from any to any #block the rest
