#!/bin/bash

echo "BEGIN capture_data.sh"
echo "Output Data to $1"
echo "Recording for $2"

ts=$(date +"%Y%m%d_%H%M%S")
echo "Timestamp $ts"

/home/rcollins/git/OAT/rpi/capture_adsb.sh "${1}/adsb" $(($2+15)) $ts&
/home/rcollins/git/OAT/rpi/capture_movie.sh "${1}/movie" $2 $ts&

