#!/bin/sh

echo "BEGIN capture_adsb.sh"
echo "Writing output to $1"
echo "Recording for $2 s"

timestamp(){
        date +"%s"
}

mkdir -p $1

# timeout $2 /home/rcollins/git/OAT/rpi/dump1090/dump1090 >> "${1}/$(timestamp)"
if pgrep dump1090; then kill $(pgrep dump1090); fi

timeout $2 /home/rcollins/git/OAT/rpi/dump1090/dump1090 >> "${1}/${3}.adsb"