# Introduction

This script automatically downloads files from a remote server to a local folder/NAS.

# Structure

* `rsyncData.sh` : main script
* `launch.sh` : script that check if the screen corresponding to the main script is running
* `kill.sh` : force the stop of the screen corresponding to the main script
* `config.txt` : configuration file

# Configuation file

In order to setup the script, you need to edit this file. Please respect the following convention

```
VARIABLE_NAME=VALUE
```

The following parameters are available :

* `DESTINATION` : local destination of the downloaded files
* `TEMP_FILE` : location of a temp file (to store the list of files to download)
* `LOCK_FILE` : location of a temp file (flag to not run the script multiple time)
* `REMOTE_USER` : user of the remote server
* `REMOTE_IP` : IP of the remote server
* `REMOTE_PORT` : SSH port of the remote server (default is 22)
* `REMOTE_PATH_DATA` : Path of the data to download on the remote server 
* `ACTIVATE_MAIL` :  value '1' activate the mail and '0' disable this function
* `IP_MAIL` : IP of server used to send mail (must have the command 'mail' configured)
* `USER_MAIL` : user of the mail server
* `PORT_MAIL` : SSH port of the mail server (default is 22)
* `EMAIL_MAIL` : email where the reports are sent
* `SCREEN_NAME` : name of the screen where the script run
* `PATH_TO_SCRIPT`: local path to the main script

Note: If you want to activate the mail reporting (a mail will be sent to you after each syncronasation), you must specify the parameters *_MAIL

Note 2: You need to allow authentication using public/private key on your remote server.

# Cron configuration

I want the script to run only between 8am to 6pm. Here is my crontab configuration

```
* 8-18 * * * /path/to/script/launch.sh >/dev/null 2>&1
5 18 * * * /path/to/script/kill.sh >/dev/null 2>&1
```

The first line checks that the screen corresponding to the script is running. If not, the screen is launched. This script will be executed between 8am to 6pm. The second line launches the script that kill the screen at 6:05pm in order to stop it and respect the schedule.

# Example of setup

In my case I have a folder located on a remote server (not inside my LAN) that I want to synchronise with a Synology NAS. As not all the shell commands are available on the NAS, I chose to use a raspberry pi as an intermediate. The NAS destination folder is mounted on the raspberry using NFS. We run the script on the Raspberry Pi.

```
DESTINATION=/home/pi/NFS/data/autosynced/
TEMP_FILE=/tmp/todo.tmp
LOCK_FILE=/tmp/lock.tmp
REMOTE_USER=user
REMOTE_IP=1.1.1.1
REMOTE_PORT=22
REMOTE_PATH_DATA=/home/user/finished/
ACTIVATE_MAIL=1
IP_MAIL=2.2.2.2
USER_MAIL=user
PORT_MAIL=22
EMAIL_MAIL=email@provider.com
SCREEN_NAME=rsyncData
PATH_TO_SCRIPT=/home/valentin/
```

Remote server (IP 1.1.1.1) <--- Internet ---> Raspberry Pi <--- Local network ---> NAS
Mail server (IP 2.2.2.2)   <--- Internet --->

