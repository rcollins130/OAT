#!/bin/sh

echo "BEGIN capture_adsb.sh"
echo "Writing output to $1"
echo "Recording for $2 s"

timeout $2 ./dump1090/dump1090 --raw >> $1&
