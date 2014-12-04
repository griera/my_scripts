#!/bin/bash

############################################################################
#                                                                          #
# my_backup_smartphone.sh:                                                 #
#                                                                          #
# Usage: my_backup_smartphone.sh                                           #
#                                                                          #
# Transfers the most recent backup of system+user apps and data made by    #
# Titanium Backup app from my smartphone to my desktop computer.           #
#                                                                          #
# Exit status:                                                             #
# · 0 -> Success                                                           #
# · 1 -> Fail (bad function usage, wrong number or defined argument. etc.) #
# · 2 -> Source is not running any rsync server                            #
#                                                                          #
############################################################################

# Home router starts on .100 to assign IPs for each device connected to the network
HOME_NETID="192.168.2"

# This module has been configured on smartphone by using Servers Ultimate Pro app.
# rsync server can be found by installing Servers Pack A
SMARTPHONE_MODULE="TitaniumBackup"

BAK_DIR="${HOME}/my_links/Smartphones/Nexus5/TitaniumBackup/"
RSYNC_PORT=873
RSYNC_OPTS="--force --ignore-errors --delete -avz --stats"

# Timeout for nc command to check the availability of rsync server
TIMEOUT=2

function usage () {
    echo -e "Usage: ${0}\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

# Searches which private IP has been assigned to the smartphone by home router
# and if source is running rsync server on rsync port (873 by default)
function search_smartphone_ip () {
    for hostid in $(seq 100 1 254) ; do
        SMARTPHONE_IP="${HOME_NETID}.${hostid}"
        nc -z -w $TIMEOUT $SMARTPHONE_IP $RSYNC_PORT
        if [ $? -eq 0 ] ; then
            return 0
        fi
    done
    return 2
}

# Checks input parameters
if [ $# -gt 0 ] ; then
    usage
fi

echo -e "Searching for the smartphone IP assigned in the network...\n"
search_smartphone_ip

if [ $? -eq 2 ] ; then
    echo "The smartphone is not running rsync server on port ${RSYNC_PORT} or isn't connected to the same network."
    echo "Please check if the smartphone is connected to the same network and is running rsync server before executing the script again."
    exit 2
fi

echo -e "SUCCESS: Smartphone has assigned ${SMARTPHONE_IP}\n"

# Starting the backup transfer
echo -e "STARTING BACKUP TRANSFER...\n"
rsync $RSYNC_OPTS ${SMARTPHONE_IP}::${SMARTPHONE_MODULE} $BAK_DIR

if [ $? -ne 0 ] ; then
    echo -e "\nERROR: Backup has not been transferred successfully due to rsync errors."
    exit 1
fi

echo -e "\nSUCCESS: Backup has been transferred on $BAK_DIR successfully!"
exit 0

