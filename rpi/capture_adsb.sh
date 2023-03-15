#!/bin/sh

echo "BEGIN capture_adsb.sh"
echo "Writing output to $1"
echo "Recording for $2 s"

timestamp(){
        date +"%s"
}

mkdir $1

timeout $2 ~git/OAT/rpi/dump1090/dump1090 --raw >> "${1}/$(timestamp)"