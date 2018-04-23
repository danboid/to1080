#!/bin/bash

# to1080 v1.0
#
# to1080 uses ffmpeg to batch convert a directory of 4K MP4 files into 1080p x264 encoded files.
# The 1080p res files are placed into a sub-directory called 1080.
#
# by Dan MacDonald

if ! [ -x "$(command -v ffmpeg)" ]; then
  echo to1080 requires ffmpeg
  exit 1
fi

BASEDIR=$1
if [ "$BASEDIR" == "" ]; then
      echo You must specify a base directory
      exit 1
fi

cd $BASEDIR
BASEDIR=`pwd`

if [ ! -d "1080" ]; then
  mkdir 1080
fi

for f in *.mp4; do
	RES=$(ffmpeg -i "$f" -hide_banner 2>&1 >/dev/null | sed -n 9p | cut -d ',' -f 3)
	ROT=$(ffmpeg -i "$f" -hide_banner 2>&1 >/dev/null | sed -n 11p | awk '{print $1}')
	if [ "$RES" != " 3840x2160" ]; then
		echo $f is not a 4k video file
	else
		if [ "$ROT" == "rotate" ]; then
			echo Encoding $f as a 90 degree rotated 1080 x264 video
			ffmpeg -v quiet -stats -i "$f" -c:v libx264 -preset veryfast -s 1920x1080 -vf "transpose=2" ./1080/1080-"$f"
		else
			echo Encoding $f as a 1080 x264 video
			ffmpeg -v quiet -stats -i "$f" -c:v libx264 -preset veryfast -s 1920x1080 ./1080/1080-"$f"
		fi
	fi
done
