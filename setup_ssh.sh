#!/bin/bash
#Setting up SSH on a bot

#ssh configuration file
ssh_config='/etc/ssh/sshd_config'

#backup the old configuration files
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
mv /etc/nologin /etc/nologin.bak
mv /etc/host.allow /etc/host.allow.bak
mv /etc/hosts.deny /etc/hosts.deny.bak

#make new configuration files
echo "Protocol 2" > $sshd_config #only allow the latest ssh standard
echo "ClientAliveInterval 300" >> $sshd_config #auto disconnect idle hosts
echo "ClientAliveCountMax 0" >> $sshd_config
echo "IgnoreRhosts yes" >> $sshd_config #disable rsh access
echo "HostBasedAuthentication no" >> $sshd_config
echo "PermitRootLogin no" >> $sshd_config
echo "PermitEmptyPasswords no" >> $sshd_config
echo "LogLevel INFO" >> $sshd_config #not sure if this is the correct log level

#chroot users home directory

#install ssh crack blocking software



