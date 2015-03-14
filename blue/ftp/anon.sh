#!/usr/bin/env bash
#Anon FTP

#stopping
service vsftpd stop

#making a new conf file
touch /etc/vsftpd-anon.conf

#adding a new folder for anon
mkdir /home/anon_user

#writing the new conf file
echo "listen=YES" > /etc/vsftpd-anon.conf
echo "local_enable=NO" >> /etc/vsftpd-anon.conf
echo "anonymous_enable=YES" >> /etc/vsftpd-anon.conf
echo "write_enable=YES" >> /etc/vsftpd-anon.conf
echo "anon_root=/home/anon_user" >> /etc/vsftpd-anon.conf
echo "anon_max_rate=2048000" >> /etc/vsftpd-anon.conf
echo "xferlog_enable=YES" >> /etc/vsftpd-anon.conf
echo "listen_address=<<HOST IP ADDRESS HERE>>" >> /etc/vsftpd-anon.conf
echo "listen_port=21" >> /etc/vsftpd-anon.conf

#adding config file to the vsftpd instance
vsftpd /etc/vsftpd-anon.conf
service vsftpd start
