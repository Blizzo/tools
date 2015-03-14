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

#reinstalling proftpd
apt-get remove proftpd -y
apt-get install proftpd -y 

#backing up the old config file
mv /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.bak

#moving in the new config file
cp `pwd`/proftpd.conf /etc/proftpd/proftpd.conf

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
service proftpd restart
echo "DONE!"
