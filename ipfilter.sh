#!/usr/bin/env bash

path=/sbin
file=/etc/ipf/ipf.conf

#allow icmp; block bad stuffz
echo "block return-icmp(net-unr) in proto udp all" >> $file # return ICMP error packets for invalid UDP packets
echo "pass in quick proto icmp from any to any  keep state group 100" > $file
echo "pass out quick proto icmp from any to any keep state group 200" >> $file

#regular rules
echo "block in log quick all with short" >> $file
echo "pass in quick proto tcp from any to any port = 80 keep state" >> $file #web
echo "pass out quick proto tcp from any to any port = 80 keep state" >> $file #web
echo "pass in quick proto tcp from any to any port = 443 keep state" >> $file #web
echo "pass out quick proto tcp from any to any port = 443 keep state" >> $file #web
echo "pass out quick proto udp from any to any port = domain keep state" >> $file #dns


#block all else
echo "block in from any to any head 100" >> $file
echo "block out from any to any head 200" >> $file

