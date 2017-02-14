#!/bin/sh

getParam() {
	cat config.txt | grep $1 | cut  -d "=" -f2
}

screenName=$(getParam "SCREEN_NAME")

isRunning=$(screen -ls | awk "/\.$screenName\t/ {print $1}" | wc -l)

if [ $isRunning -gt 0 ]; then
	echo "Screen $screenName is running"

	screen -r "$screenName" -X quit

	echo "$screenName killed"
fi§
