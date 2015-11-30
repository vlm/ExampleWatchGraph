#!/usr/bin/env bash -eu
#
# 1. Use QuickTime to record screencast.
# 2. Save movie as .MOV (default)
# 3. Use this script to convert the first 5 seconds to animated .gif with a
#    nice palette.
#
# See http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html for details.

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file.mov> <file.gif>"
    exit 2
fi

if [ ! -f "$1" ]; then
    echo "$1: not found"
    exit 2
fi

palette="/tmp/palette-$$.png"

function cleanup() {
    rm -f ${palette}
}
trap cleanup EXIT
cleanup

start_time=00:00
duration=5
filters="fps=30,scale=-1:-1:flags=lanczos"

ffmpeg -v warning -ss $start_time -t $duration -i $1 -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -ss $start_time -t $duration -i $1 -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -f gif - | gifsicle --optimize=3 --delay=3 -k 32 > $2

