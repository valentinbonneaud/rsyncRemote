#!/bin/bash

getParam() {
	cat config.txt | grep $1 | cut  -d "=" -f2
}

destination=$(getParam "DESTINATION")
tempFile=$(getParam "TEMP_FILE")
lockFile=$(getParam "LOCK_FILE")
USER=$(getParam "REMOTE_USER")
IP=$(getParam "REMOTE_IP")
PORT=$(getParam "REMOTE_PORT")
PATH_DATA=$(getParam "REMOTE_PATH_DATA")
ACTIVATE_MAIL=$(getParam "ACTIVATE_MAIL")
IP_MAIL=$(getParam "IP_MAIL")
USER_MAIL=$(getParam "USER_MAIL")
PORT_MAIL=$(getParam "PORT_MAIL")
EMAIL_MAIL=$(getParam "EMAIL_MAIL")
tempFile=$(getParam "EMAIL_MAIL")

SCREEN_NAME=$(getParam "SCREEN_NAME")

exitFunc() {

    if [ "$SCREEN_NAME" = "" ]; then
        exit $1
    else
        screen -S "$SCREEN_NAME" -X quit
    fi

}


if [ ! -d "$destination" ]; then
    echo "Folder does not exists or is not mounted ... exiting ..."
    exitFunc -1
fi

rm "$lockFile"

if [ -f "$lockFile" ]; then
	# Already runing
    echo "Already running"
    exitFunc 0
fi

if [ ! -f "$tempFile" ]; then
    touch "$tempFile"
fi

touch "$lockFile"

ssh -p $PORT $USER@$IP ifconfig -a > /dev/null

if [ $? -eq 0 ]; then
    echo "Connected"
else
    echo "No connection, exiting ..."
    rm "$lockFile"
    exitFunc -1
fi

echo "We continue"

newFiles=$(ssh -p $PORT $USER@$IP "ls $PATH_DATA" )

if [ ! "$newFiles" == "" ]; then
    echo "$newFiles" > "$tempFile"
fi

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat "$tempFile"); do
    echo "We download: $i"

    echo "First, we resolve the symlink"
    realPath=$(ssh -p $PORT $USER@$IP "readlink -f \"$PATH_DATA$i\"")
    realSize=$(ssh -p $PORT $USER@$IP "du -sh \"$realPath\" | cut -d$'\t' -f1")
    echo "Real path is $realPath ($realSize)"
    
    start=$(date +%s)

    if [ "$ACTIVATE_MAIL" = "1" ]; then
        ssh -p $PORT_MAIL $USER_MAIL@$IP_MAIL "echo \"We start to download $i ($realSize)\" | mail -s '[NAS] Rsync finished' $EMAIL_MAIL"
    fi

    #rsync --partial --progress --rsh=ssh -P $PORT --timeout=10 $USER@$IP:"$i" "$destination"
    rsync -a --partial --progress --timeout=10 -e "ssh -p $PORT" $USER@$IP:"$realPath" "$destination"
    statusRsync=$?

    end=$(date +%s)
    timeTaken=$(( $end - $start ))

    if [ $statusRsync -eq 0 ]; then
        echo "$i : done"

        echo "we delete $PATH_DATA$i"
        ssh -p $PORT $USER@$IP "rm -r \"$PATH_DATA$i\""

        if [ "$ACTIVATE_MAIL" = "1" ]; then
            ssh -p $PORT_MAIL $USER_MAIL@$IP_MAIL "echo \"We finished to download $i ($realSize) in $timeTaken seconds\" | mail -s '[NAS] Rsync finished' $EMAIL_MAIL"
        fi

    else
        echo "$i : error"
        ssh -p $PORT_MAIL $USER_MAIL@$IP_MAIL "echo \"We have an error when downloading $i ($realSize)\" | mail -s '[NAS] Rsync error' $EMAIL_MAIL"
    fi

    ssh -p $PORT $USER@$IP ifconfig -a > /dev/null

    if [ $? -ne 0 ]; then
        echo "No connection, exiting ..."
        rm "$lockFile"
        exitFunc -1
    fi

done

rm "$tempFile"
rm "$lockFile"

exitFunc 0
