#!/usr/bin/env bash
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
	echo "Remember: must be run as root to 100% successful. When script prompts for users, it creates their home directory in the jail and assumes they already exist as users on the system and gives them ownership of their home directories. If they don't yet exist, you will have to manually change the ownership of their home directories after the script runs."
fi

copy_libraries(){
	# iggy ld-linux* file as it is not shared one
	FILES="$(/usr/bin/ldd $1 | /usr/bin/awk '{ print $3 }' |/usr/bin/egrep -v ^'\(')"

	#echo "Copying shared files/libs to $path..."
	for i in $FILES
	do
		d="$(dirname $i)"
		[ ! -d $path$d ] && /bin/mkdir -p $path$d || :
		/bin/cp $i $path$d
	done

	# copy /lib/ld-linux* or /lib64/ld-linux* to $path/$sldlsubdir
	# get ld-linux full file location 
	sldl="$(/usr/bin/ldd $1 | /usr/bin/grep 'ld-linux' | /usr/bin/awk '{ print $1}')"
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

error_file=".jm_error"

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
	/bin/mkdir -p $path
	/bin/mkdir -p $path/{dev,etc,lib,libexec,usr,bin,home}
	/bin/mkdir -p $path/usr/bin
	user="none"
	while [ true ]; do
		read -p "Enter users to be placed in jail (leave blank if no more users): " user
		if [ "$user" = "" ]; then
			break;
		fi
		/bin/mkdir -p $path/home/$user
		/bin/chmod 750 $path/home/$user
		/usr/sbin/chown -f $user $path/home/$user
	done
	/usr/sbin/chown -f root:wheel $path
	/sbin/mknod $path/dev/null c 1 3

	#copy over bare minimum files
	/bin/cp /libexec/ld-elf.so.1 $path/libexec/ld-elf.so.1
	/bin/cp /etc/nsswitch.conf $path/etc
	/bin/cp /etc/hosts $path/etc

	#copy bare minimum executables
	/bin/cp /bin/ls $path/bin
	/bin/cp /bin/cat $path/bin
	/bin/cp /bin/sh $path/bin
	/bin/cp /bin/cp $path/bin
	/bin/cp /bin/mv $path/bin
	/bin/cp /bin/rm $path/bin
	/bin/cp /bin/mkdir $path/bin
	/bin/cp /bin/rmdir $path/bin
	/bin/cp /bin/pwd $path/bin
	/bin/cp /usr/bin/vi $path/usr/bin

	set "/bin/ls /bin/sh /bin/cat /bin/cp /bin/mv /bin/rm /bin/mkdir /bin/rmdir /bin/pwd /usr/bin/vi"

	#copy appropriate libraries
	for exec in $@; do
		copy_libraries $exec
	done 2> $error_file

	if test -e $error_file; then
		echo "Some libraries may not have copied properly"
		/bin/rm $error_file
	fi
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
	/bin/mkdir -p $path
	/bin/mkdir -p $path/{dev,etc,lib,libexec,usr,bin,home,var,tmp}
	/bin/mkdir -p $path/var/tmp
	/bin/mkdir -p $path/tmp/vi.recover
	/usr/sbin/chown 777 $path/tmp/vi.recover
	/bin/ln -s $path/tmp $path/var/tmp
	/bin/mkdir -p $path/usr/bin
	/bin/mkdir -p $path/usr/share/misc
	user="none"
	while [ true ]; do
		read -p "Enter users to be placed in jail (leave blank if no more users): " user
		if [ "$user" = "" ]; then
			break;
		fi
		/bin/mkdir -p $path/home/$user
		/bin/cp /home/$user/.* $path/home/$user &> /dev/null
		# /usr/sbin/chown -f -R $user:wheel $path/home/$user/.*
		/bin/chmod -R 750 $path/home/$user
		/usr/sbin/chown -f -R $user $path/home/$user
	done
	/usr/sbin/chown -f root:wheel $path
	/sbin/mknod $path/dev/null c 1 3

	#copy over bare minimum files
	/bin/cp /libexec/ld-elf.so.1 $path/libexec
	/bin/cp /etc/termcap.small $path/etc
	/bin/cp /usr/share/misc/termcap $path/usr/share/misc
	/bin/cp /etc/nsswitch.conf $path/etc
	/bin/cp /etc/hosts $path/etc

	#ask and copy executables
	echo "Which executables would you like in your jail?"
	common_bins=`ls /bin`

	for i in $common_bins; do
		read -p "$i (Y/N):" choice
		choice=`echo $choice | tr '[:lower:]' '[:upper:]'`
		if [ "$choice" = "Y" -o "$choice" = "YES" ]; then
			/bin/cp /bin/$i $path/bin
			bins+="/bin/$i "
		fi
	done

	read -p "Would you like to choose between a few common binaries in /usr/bin (Y/N): " more_bins
	more_bins=`echo $more_bins | tr '[:lower:]' '[:upper:]'`
	if [ "$more_bins" = "YES" -o "$more_bins" = "Y" ]; then
		other_bins="awk clear cut diff expr head less man nano paste pico split strings strip tail tee test touch tr uniq users uptime vi w wall wc wget whatis who whoami yes zip zipgrep"

		for i in $other_bins; do
			read -p "$i (Y/N):" choice
			choice=`echo $choice | tr '[:lower:]' '[:upper:]'`
			if [ "$choice" = "Y" -o "$choice" = "YES" ]; then
				/bin/cp /usr/bin/$i $path/usr/bin
				bins+="/usr/bin/$i "
			fi
		done
	fi

	#copy appropriate libraries
	set $bins

	for exec in $@; do
		copy_libraries $exec
	done 2> $error_file

	if test -e $error_file; then
		echo "Some libraries may not have copied properly"
		/bin/rm $error_file
	fi
fi
