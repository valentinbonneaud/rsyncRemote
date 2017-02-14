#!/bin/sh

getParam() {
	cat config.txt | grep $1 | cut  -d "=" -f2
}

screenName=$(getParam "SCREEN_NAME")
pathToScript=$(getParam "PATH_TO_SCRIPT")

isRunning=$(screen -ls | awk "/\.$screenName\t/ {print $1}" | wc -l)

if [ $isRunning -gt 0 ]; then
	echo "Screen $screenName already running"
	exit
fi

screen -S "$screenName" -dm
screen -r "$screenName" -X stuff "$pathToScript/rsyncData.sh\n"
echo "$screenName launched"
