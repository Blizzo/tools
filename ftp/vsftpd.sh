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
wget -q http://ftp.debian.org/debian/pool/main/v/vsftpd/vsftpd_3.0.2-3_i386.deb
echo "Finished downloading..."

#backing up the old config file (if there is one)
mv /etc/vsftpd.conf /etc/vsftpd.conf.bak

#installing and moving custom configuration in
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
service vsftpd start
echo "DONE! Finished installing vsftpd"

#removing install file
cd $OLDPWD
rm vsftpd_3.0.2-3_i386.deb
