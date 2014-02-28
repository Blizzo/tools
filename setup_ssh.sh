#!/usr/bin/env bash
#Setting up SSH on a box

#ssh configuration file
sshd_config='/etc/ssh/sshd_config'

service sshd stop

#backup the old configuration files
/bin/cp $sshd_config $sshd_config.bak
/bin/mv /etc/nologin /etc/nologin.bak
/bin/mv /etc/host.allow /etc/host.allow.bak
/bin/mv /etc/hosts.deny /etc/hosts.deny.bak

#make new configuration files
echo "Protocol 2" > $sshd_config #only allow the latest ssh standard
echo "Port 22" >> $sshd_config #set port
echo "X11Forwarding no" >> $sshd_config
echo "ClientAliveInterval 300" >> $sshd_config #auto disconnect idle hosts
echo "ClientAliveCountMax 0" >> $sshd_config
echo "IgnoreRhosts yes" >> $sshd_config #disable rsh access
echo "RhostsRSAAuthentication no" >> $sshd_config
echo "HostBasedAuthentication no" >> $sshd_config
echo "ChallengeResponseAuthentication yes" >> $sshd_config
echo "UsePAM yes" >> $sshd_config
echo "PermitRootLogin no" >> $sshd_config
echo "PermitEmptyPasswords no" >> $sshd_config
echo "LogLevel INFO" >> $sshd_config

#chroot users home directory
echo "ChrootDirectory /var/jail" >> $sshd_config #set up chroot dir
echo "AllowTcpForwarding no" >> $sshd_config

service sshd start
