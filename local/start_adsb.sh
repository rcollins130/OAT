#!/bin/sh

echo "BEGIN start_adsb.sh"
echo "Remote write to $1"
echo "Remote write for $2"
echo "rsync to $3"

ssh rcollins@raspberrypi.local "~/git/OAT/rpi/capture_adsb.sh $1 $2"

rsync -r --remove-source-files rcollins@raspberrypi.local:$1 $3

