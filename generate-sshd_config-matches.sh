#!/bin/bash

###############################################################################
#
# PURPOSE: This script generates "Match address entires for the /etc/ssh/sshd_config file.
#
# USAGE:  ./ispIPs.sh [an ip address] > IPs.txt; ./generate-sshd_config-matches.sh IPs.txt >> /etc/ssh/sshd_config
#
# AUTHOR: John Lucas
#
# CREATED ON: 2023-09-01
#
################################################

# Debug to see what is happening as script executes
#set -x

while IFS= read -r line
do
        echo ""
        echo "Match address $line"
        echo "  PasswordAuthentication yes"

done <"IPs.txt"
