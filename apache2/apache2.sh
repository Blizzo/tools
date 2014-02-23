#!/usr/bin
#apache2 statup

##NOT SURE IF WE WANT TO REINSTALL
##stopping apache server
##service apache2 stop
##
##uninstalling and reinstalling
##sudo apt-get remove apache2 -y
##sudo apt-get instal apache2 -y

#stopping apache server
service apache2 stop

#making a backup of the fresh configs
mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
mv /etc/apache2/ports.conf /etc/apache2/ports.conf.bak

#moving premade config to apache dir
mv `pwd`/apache2.conf /etc/apache2/apache2.conf

#making the new ports.conf file
echo "NameVirtualHost *:80" >> /etc/apache2/ports.conf
echo "Listen 80" >> /etc/apache2/ports.conf
echo "<IfModule mod_ssl.c>" >> /etc/apache2/ports.conf
echo "</IfModule>" >> /etc/apache2/ports.conf
echo "<IfModule mod_gnutls.c>" >> /etc/apache2/ports.conf
echo "    Listen 443" >> /etc/apache2/ports.conf
echo "</IfModule>" >> /etc/apache2/ports.conf

#restarting service
service apache2 restart
