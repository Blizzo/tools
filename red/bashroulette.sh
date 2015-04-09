#!/bin/bash

sleepTime=30

#get shell for the user
shell="$(getent passwd "$(whoami)" | awk -F : '{print $NF}' | awk -F / '{print $NF}')"
if [ "$shell" = "" ]; then
    shell="bash"
fi

#make sure history file exists and whatnot
histFile="$HOME/.${shell}_history"
if [ ! -e "$histFile" ]; then
    histFile="$HOME/.history"
    if [ ! -e "$histFile" ]; then
        echo "couldn't find history file :("
        exit -1
    fi
fi

#roulette forever!
while true; do
    lines="$(wc -l "$histFile" | awk '{print $1}')"
    rand="$(($RANDOM % $lines))"
    cmd="$(sed "${rand}q;d" "$histFile")"
    echo "$cmd"
    $cmd

    sleep "$sleepTime"
done
