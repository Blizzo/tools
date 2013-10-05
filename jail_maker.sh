#!/bin/bash
# Author: Luke Matarazzo
# Copyright (c) 2013, Luke Matarazzo
# All rights reserved.

if [ "$1" = "-h" -o "$1" = "--help" ]; then
	echo "Usage:  ./jail_maker [OPTION] [JAIL_PATH]"
	#echo "	./jail_maker [CONFIG_FILE]"
	echo "Note: must be run as root."
	echo "Create a jail environment to be used as in a chroot jail configuration."
	echo ""
	echo "Invoking the script without any parameters will enter the script in manual configuration mode in which it will prompt you on how to create the jail"
	echo "	-h, --help 	print this help information"
	echo "	-s, --secure 	configure a very secure jail with the bare minimum"
	echo "			of executables and libraries"
	echo ""
	echo "Remember: must be run as root to be 100% successful"
fi

copy_libraries(){
	# iggy ld-linux* file as it is not shared one
	FILES="$(ldd $1 | awk '{ print $3 }' |egrep -v ^'\(')"

	#echo "Copying shared files/libs to $path..."
	for i in $FILES
	do
		d="$(dirname $i)"
		[ ! -d $path$d ] && mkdir -p $path$d || :
		/bin/cp $i $path$d
	done

	# copy /lib/ld-linux* or /lib64/ld-linux* to $path/$sldlsubdir
	# get ld-linux full file location 
	sldl="$(ldd $1 | grep 'ld-linux' | awk '{ print $1}')"
	# now get sub-dir
	sldlsubdir="$(dirname $sldl)"

	if [ ! -f $path$sldl ];
	then
		#echo "Copying $sldl $path$sldlsubdir..."
		/bin/cp $sldl $path$sldlsubdir
	else
		:
	fi
}

if [ "$1" = "-s" -o "$1" = "--secure" ]; then
	if [ "$#" -ne 2 ]; then
		echo "A jail path must be specified with the --secure (-s) option."
		exit 1
	fi

	shift
	echo "Initializing secure jail setup..."
	if test -d $1; then
		cd $1
		path=`echo $PWD`
	else
		path="$1"
	fi
	shift

	#set up jail environment directories
	mkdir -p $path
	mkdir -p $path/{dev,etc,lib,usr,bin,home}
	mkdir -p $path/usr/bin
	user="none"
	while [ "$user" != "" ]; do
		read -p "Enter users to be placed in jail (leave blank if no more users): " user
		mkdir -p $path/home/$user
	done
	chown root.root $path
	mknod -m 666 $path/dev/null c 1 3

	#copy over bare minimum files
	cp /etc/ld.so.cache $path/etc
	cp /etc/ld.so.conf $path/etc
	cp /etc/nsswitch.conf $path/etc
	cp /etc/hosts $path/etc

	#copy bare minimum executables
	cp /bin/ls $path/bin
	cp /bin/cat $path/bin
	cp /bin/cp $path/bin
	cp /bin/mv $path/bin
	cp /bin/rm $path/bin
	cp /bin/mkdir $path/bin
	cp /bin/rmdir $path/bin
	cp /bin/dir $path/bin
	cp /bin/pwd $path/bin
	cp /usr/bin/vi $path/usr/bin

	set "/bin/ls /bin/cat /bin/cp /bin/mv /bin/rm /bin/mkdir /bin/rmdir /bin/dir /bin/pwd /usr/bin/vi"

	#copy appropriate libraries
	for exec in $@; do
		copy_libraries $exec
	done
fi

if [ "$#" -eq 0 ]; then
	echo "Initializing manual setup"
	read -p "Enter path of jail directory: " dir
	if test -d $dir; then
		cd $dir
		path=`echo $PWD`
	else
		path="$dir"
	fi

	#set up jail environment directories
	mkdir -p $path
	mkdir -p $path/{dev,etc,lib,usr,bin,home}
	mkdir -p $path/usr/bin
	user="none"
	while [ "$user" != "" ]; do
		read -p "Enter users to be placed in jail (leave blank if no more users): " user
		mkdir -p $path/home/$user
	done
	chown root.root $path
	mknod -m 666 $path/dev/null c 1 3

	#copy over bare minimum files
	cp /etc/ld.so.cache $path/etc
	cp /etc/ld.so.conf $path/etc
	cp /etc/nsswitch.conf $path/etc
	cp /etc/hosts $path/etc

	#prompt for which executables they would like

fi
