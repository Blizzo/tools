#!/usr/bin/env bash

#Setting up VSFTPD
apt-get install vsftpd
rm /etc/vsftpd.conf
cp vsftpd.conf /etc/vsftpd.conf
cd /var/run/vsftpd
chattr +i vsftp.conf

#making the chroot
rm -r empty
mkdir dump
find /var/run/vsftpd/dump -type d -exec chmod 777 {} \;

#restarting
service vsftpd restart
