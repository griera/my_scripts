#!/bin/bash

###############################################################################
#                                                                             #
# my_backup_smartphone.sh:                                                    #
#                                                                             #
# Usage: my_backup_smartphone.sh [pushbullet_token]                           #
#                                                                             #
# Transfers the most recent backup of system+user apps and data made by       #
# Titanium Backup app from my smartphone to my desktop computer.              #
#                                                                             #
# If a pushbullet access token is specified, the script will send a           #
# notification to all devices granted to this pushbullet account.             #
#                                                                             #
# Exit status:                                                                #
# · 0 -> Success                                                              #
# · 1 -> Fail (bad function usage, wrong number or defined argument. etc.)    #
# · 2 -> Source is not running any rsync server                               #
#                                                                             #
###############################################################################

# Static IP assignment from my home router
SMARTPHONE_IP="192.168.1.11"

# This module has been configured on smartphone by using Servers Ultimate Pro app.
# rsync server can be found by installing Servers Pack A
SMARTPHONE_MODULE="TitaniumBackup"

BAK_DIR="${HOME}/my_links/smartphones/Nexus5/TitaniumBackup/"
RSYNC_PORT=873
RSYNC_OPTS="--force --ignore-errors --delete -avz --stats"

# Pushbullet script
SEND_PUSHBULLET_NOTIF="${HOME}/repos/my_scripts/my_send_pushbullet_notif.sh"

# Title for pushbullet notifications
TITLE="$(basename $0)"

function usage () {
    echo -e "Usage: ${0}\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

# Checks input parameters
if [ $# -gt 1 ] ; then
    usage
fi

ACCESS_TOKEN="$1"

# Starting the backup transfer
echo -e "STARTING BACKUP TRANSFER...\n"
rsync $RSYNC_OPTS ${SMARTPHONE_IP}::${SMARTPHONE_MODULE} $BAK_DIR

if [ $? -ne 0 ] ; then
    mesg="ERROR: Backup has not been transferred successfully due to rsync errors."
    echo -e "\n${mesg}"
    if [ "x${ACCESS_TOKEN}" != "x" ] ; then
        $SEND_PUSHBULLET_NOTIF "$ACCESS_TOKEN" "$TITLE" "$mesg"
    fi
    exit 1
fi

mesg="SUCCESS: Backup has been transferred on $BAK_DIR successfully!"
echo -e "\n${mesg}"
if [ "x${ACCESS_TOKEN}" != "x" ] ; then
    $SEND_PUSHBULLET_NOTIF "$ACCESS_TOKEN" "$TITLE" "$mesg"
fi
exit 0

