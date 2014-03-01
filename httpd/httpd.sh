#!/bin/bash
#Installing httpd

#installing if not already there
yum install httpd -y

#stopping
service httpd stop

#editing home page
cd /var/www/html
touch index.html
echo "HEY" >> index.html

#moving in conf file
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
mv `pwd`/httpd.conf /etc/httpd/conf/httpd.conf

#reloading and restarting
service httpd reload
service httpd restart


##installing mod sec
#yum install gcc make
#yum install libxml2 libxml2-devel httpd-devel pcre-devel curl-devel
#cd /usr/src
#wget http://www.modsecurity.org/download/modsecurity-apache_2.6.6.tar.gz
#tar xzf modsecurity-apache_2.6.6.tar.gz
#cd modsecurity-apache_2.6.6
#./configure
#make install
#cp modsecurity.conf-recommended /etc/httpd/conf.d/modsecurity.conf

