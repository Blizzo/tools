#!/bin/bash

sleepTime=30
histFile="$HOME/.bash_history"

while true; do
    lines="$(wc -l "$histFile" | awk '{print $1}')"
    rand="$(($RANDOM % $lines))"
    cmd="$(sed "${rand}q;d" "$histFile")"
    echo "$cmd"
    $cmd

    sleep "$sleepTime"
done
