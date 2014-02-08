#!/usr/bin/env bash
#Getting ftpd up and running

#Asking to see if they have a ftp user
read -p "Do you have an FTP User? (y/n)" ANS
if [ "ANS" == "y" ]; then
   read -p "What's the user's name?" FTPUSER
else
   echo "Please make a user FIRST!"
   exit
fi

#Setting up VSFTPD
apt-get -y install vsftpd
rm /etc/vsftpd.conf
cp ftpconfigfile /etc/vsftpd.conf
cd /var/run/vsftpd
#chattr +i vsftp.conf

#making the chroot
cd /home
rm -r $FTPUSER
mkdir $FTPUSER
chmod a-w /$FTPUSER

#restarting
service vsftpd restart
