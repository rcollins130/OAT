#!/bin/bash

# capture string of images from camera

echo "BEGIN capture_movie.sh"
echo "Copy movie to $1"
echo "Recording for $2 s"

# gphoto2 --capture-movie 30s --stdout | ffmpeg -i - -y -pix_fmt yuv420p -b:v 4000k -c:v libx264 test.mp4 
mkdir -p $1
kill $(pgrep gphoto2)

pushd $1
gphoto2 \
    --set-config viewfinder=1 \
    --wait-event 1s \
    --set-config capturetarget='Memory card' \
    --wait-event 1s \
    --set-config movierecordtarget=Card \
    --wait-event "${2}s" \
    --set-config movierecordtarget=None \
    --wait-event 1s \
    --wait-event-and-download 2s \

gphoto2 \
    -P \

gphoto2 \
    -D --recurse \

mv MVI_*.MP4 "${3}.mp4"

popd