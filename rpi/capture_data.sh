#!/bin/bash

echo "BEGIN capture_data.sh"
echo "Output Data to $1"
echo "Recording for $2"

/home/rcollins/git/OAT/rpi/capture_adsb.sh "${1}/adsb" $2 &
/home/rcollins/git/OAT/rpi/capture_movie.sh "${1}/movie" $2 &

