#!/bin/bash
#Setting up SSL on apache2

#ask if they've installed before
read -p "Have you generated your SSL Cert? [y/n]: " ANS

#if this is the first time
if [ "$ANS" == "n" ]; then
   #enabling
   a2enmod ssl
   service apache2 restart

   #making a new dir
   mkdir /etc/apache2/ssl
   cd /etc/apache2/ssl
   echo "Run the following command:"
   echo "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt"
   exit

#if they've run the script before
elif [ "$ANS" == "y" ]; then
   mv /etc/apache2/sites-available/default-ssl /etc/apache2/sites-available/default-ssl.bak
   mv `pwd`/default /etc/apache2/sites-available/default-ssl
   a2ensite default-ssl
   service apache2 reload
   echo "Remember to edit the default-ssl config file!"
   exit

#if a wrong selection
else
   echo "Incorrect selection"
   exit
fi
