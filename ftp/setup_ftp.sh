#!/usr/bin/env bash
#Gettng ftp server up and running
#This works for vsftp and proftpd currently

#Asking to see if they have a ftp user
read -p "Do you have an FTP User? (y/n): " ANS
answer=`echo $ANS | tr '[:lower:]' '[:upper:]'`
if [ "$ANS" == "Y" ]; then
   read -p "User's name: " FTPUSER
else
   echo "Please make a user FIRST!"
   exit
fi

#checking to see if vsftpd is installed
if [ -f "/etc/vsftpd.conf" ]; then
   VERSION='vsftpd'
   echo "Looks like VSFTPD is already installed!"
   service $VERSION stop
   
   #putting the new config file in
   mv /etc/vsftpd.conf /etc/vsftpd.config.bak
   cp vsftpd.conf /etc/vsftpd.conf
fi

#checking to see if proftp is installed
if [ -f "/etc/proftpd/proftpd.conf" ]; then
   VERSION='proftpd'
   echo "Looks like ProFTP is already installed!"
   service $VERSION stop
   
   #putting the new config file in
   mv /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.bak
   cp proftp.conf /etc/proftpd/proftpd.conf 
fi

#managing the FTP dir
cd /home
rm -r $FTPUSER
mkdir $FTPUSER

#restarting
service $VERSION restart
