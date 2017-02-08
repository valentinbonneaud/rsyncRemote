# Introduction

This script automatically download files from a remote server to a local folder/NAS.

# Structure

* rsyncData.sh : main script
* launch.sh : script that check if the screen corresponding to the main script is running
* kill.sh : force the stop of the screen corresponding to the main script
* config.txt : configuration file

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
* `IP_MAIL` : IP of server used to send mail (must have the command 'mail' configured)
* `USER_MAIL` : user of the mail server
* `PORT_MAIL` : SSH port of the mail server (default is 22)
* `EMAIL_MAIL` : email where the reports are sent

Note: If you want to activate the mail reporting (a mail will be sent to you after each syncronasation), you must specify the parameters *_MAIL

Note 2: You need to allow authentication using public/private key on your remote server.

# Cron configuration

I want the script running only between 8am to 6pm. Here is my crontab configuration

```
* 8-18 * * * /path/to/script/launch.sh >/dev/null 2>&1
5 18 * * * /path/to/script/kill.sh >/dev/null 2>&1
```

The first line check that the screen corresponding to the script is running. If not, the screen is launched. This script will be executed between 8am to 6pm. The second line launch the script that kill the screen at 6:05pm in order to stop it and respect the schedule.

# Example of setup

