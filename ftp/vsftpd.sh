#!/usr/bin/env bash
#Gettng ftp server up and running
#This works for vsftp and proftpd currently

#Asking to see if they have a ftp user
read -p "Do you have FTP User(s)? (y/n): " ANS
ANS=`echo $ANS | tr '[:lower:]' '[:upper:]'`
if [ "$ANS" == "Y" ]; then
   read -p "Enter user(s) name (separate each with a space): " FTPUSERS
else
   echo "Please make a user FIRST!"
   exit
fi

#checking to see if vsftpd is installed
apt-get remove vsftp -y
wget http://ftp.debian.org/debian/pool/main/v/vsftpd/vsftpd_3.0.2-3_i386.deb
 
#backing up the old config file
mv /etc/vsftpd.conf /etc/vsftpd.conf.bak

#installing
dpkg -i vsftpd_3.0.2-3_i386.deb
cp vsftpd3.conf /etc/vsftpd.conf

#making a chroot for each user
cd /home
for FTPUSER in $FTPUSERS; do
   if test ! -e $FTPUSER; then
      mkdir $FTPUSER
      chown $FTPUSER:$FTPUSER $FTPUSER/
      chmod 755 $FTPUSER/
   fi
done

#restarting
service vsftpd stop
kill `ps -eo pid,command | grep "vsftpd" | grep -v grep | awk '{print $1}'`
service vsftpd start

#removing install file
rm vsftpd_3.0.2-3_i386.deb
