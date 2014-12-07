#!/bin/bash

###############################################################################
#                                                                             #
# my_send_pushbullet_notif.sh:                                                #
#                                                                             #
# Usage: my_send_pushbullet_notif.sh token "title" "body"                     #
#                                                                             #
# Sends a notification with title "title" and "body" as its message to all    #
# devices available on pushbullet accound specified by its access token.      #
#                                                                             #
# Both title and body must be enclosed in double quotation marks.             #
#                                                                             #
# Exit status:                                                                #
# · 0 -> Success                                                              #
# · 1 -> Fail (bad function usage, wrong number or defined argument. etc.)    #
#                                                                             #
###############################################################################

function usage () {
    echo -e "Usage: ${0} access_token \"title\" \"body\"\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

# Checks input parameters
if [ $# -ne 3 ] ; then
    usage
fi

# The colon ':' after access token is mandatory (see Pushbullet API Documentation)
ACCESS_TOKEN="$1:"

TITLE="$2"
BODY="$3"
API_DEVICES="https://api.pushbullet.com/api/devices"
API_PUSHES="https://api.pushbullet.com/api/pushes"

IFS=$','
for attr in "$(curl $API_DEVICES -u ${ACCESS_TOKEN} 2> /dev/null)" ; do
    dev_iden="$(echo $attr | grep iden)"
    if [ "x$dev_iden" != "x" ] ; then
        list_dev_idens="${list_dev_idens},$(echo $dev_iden | cut -d ':' -f2)"
    fi
done

for iden in $list_dev_idens ; do
    curl $API_PUSHES -u ${ACCESS_TOKEN}: -d device_iden=$iden -d type=note -d title="$TITLE" -d body="$BODY" -X POST &> /dev/null
done

exit 0
