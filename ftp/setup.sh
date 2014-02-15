#!/usr/bin/env bash
#Getting ftp server up and running
#This works for vsftp currently
#Asking to see if they have a ftp user
read -p "Do you have an FTP User? (y/n): " ANS
if [ "ANS" == "y" ]; then
   read -p "User's name: " FTPUSER
else
   echo "Please make a user FIRST!"
   exit
fi

#checking to see what version of FTP is installed
if [ -f "/etc/vsftpd.conf" ]; then
   echo "Looks like VSFTPD is already installed!"
   service vsftpd stop
   
   #putting the new config file in
   rm /etc/vsftpd.conf
   cp ftpconfigfile /etc/vsftpd.conf
   
   #managing the FTP dir
   cd /home
   rm -r $FTPUSER
   mkdir $FTPUSER

   #chmod a-w /$FTPUSER
fi

#restarting
service vsftpd restart
