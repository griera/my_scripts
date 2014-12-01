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

function usage () {
    echo -e "Usage: ${0}\n"
    echo -e "More information can be found by reading the script file."
    exit 1
}

# Checks input parameters
if [ $# -gt 0 ] ; then
    usage
fi

SMARTPHONE_IP="192.168.2.102"

# This module has been configured on smartphone by using Servers Ultimate Pro app.
# rsync server can be found by installing Servers Pack A
SMARTPHONE_MODULE="TitaniumBackup"

BAK_DIR="${HOME}/my_links/Smartphones/Nexus_5/TitaniumBackup/"
RSYNC_PORT=873
RSYNC_OPTS="--force --ignore-errors --delete -avz --stats"

# Timeout for nc command to check the availability of rsync server
TIMEOUT=3

# Checks if source is running rsync server on rsync port (873 by default)
nc -z -w $TIMEOUT $SMARTPHONE_IP $RSYNC_PORT

if [ $? -ne 0 ] ; then
    echo "The smartphone (${SMARTPHONE_IP}) is not running rsync server on port ${RSYNC_PORT}. Please start rsync on it and execute again the script."
    exit 2
fi

# Starting the backup transfer
echo -e "STARTING BACKUP TRANSFER...\n"
rsync $RSYNC_OPTS ${SMARTPHONE_IP}::${SMARTPHONE_MODULE} $BAK_DIR

if [ $? -ne 0 ] ; then
    echo -e "\nERROR: Backup has not been transferred successfully due to rsync errors."
    exit 1
fi

echo -e "\nSUCCESS: Backup has been transferred on $BAK_DIR successfully!"
exit 0

