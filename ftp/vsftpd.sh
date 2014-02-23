#!/usr/bin/env bash
#Gettng ftp server up and running
#This works for vsftp and proftpd currently

#Asking to see if they have a ftp user
read -p "Do you have an FTP User? (y/n): " ANS
ANS=`echo $ANS | tr '[:lower:]' '[:upper:]'`
if [ "$ANS" == "Y" ]; then
   read -p "User's name: " FTPUSER
else
   echo "Please make a user FIRST!"
   exit
fi

#checking to see if vsftpd is installed
sudo apt-get remove vsftp -y
wget http://ftp.debian.org/debian/pool/main/v/vsftpd/vsftpd_3.0.2-3_i386.deb
 
#backing up the old config file
mv /etc/vsftpd.conf /etc/vsftpd.conf.bak

#installing
dpkg -i vsftpd_3.0.2-3_i386.deb
cp vsftpd3.conf /etc/vsftpd.conf

#making a chroot
cd /home

mkdir $FTPUSER
chown $FTPUSER:$FTPUSER $FTPUSER/
chmod 755 $FTPUSER/

#restarting
service vsftpd stop
service vsftpd start
