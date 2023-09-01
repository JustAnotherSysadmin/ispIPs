#!/bin/bash

###############################################################################
#
# PURPOSE: This script takes in an IP address owned by an ISP and outputs
#          all IP addresses owned by that ISP in CIDR notation.
#
# AUTHOR: John Lucas
#
# CREATED ON: 2023-09-01
#
################################################

# Debug to see what is happening as script executes
#set -x


################################################
# __     __         _       _     _
# \ \   / /_ _ _ __(_) __ _| |__ | | ___  ___
#  \ \ / / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#   \ V / (_| | |  | | (_| | |_) | |  __/\__ \
#    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#
################################################

# This is the list of IPs that will be written to a temp file
TEMPIPLISTFILE=/tmp/tempIPlistfile.txt

# command line input
IPINQUESTION=$1


################################################
#  _____                 _   _
# |  ___|   _ _ __   ___| |_(_) ___  _ __  ___
# | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
# |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
# |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#
################################################


# This funciton is by Mitch Frazier dated June 26, 2008
# on page: https://www.linuxjournal.com/content/validating-ip-address-bash-script
function valid_ip() {
        local  ip=$1
        local  stat=1

        if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                OIFS=$IFS
                IFS='.'
                ip=($ip)
                IFS=$OIFS
                [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
                        && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
                stat=$?
        fi
        return $stat
}


# Input error checking
function isvalidinput() {
        #check if user supplied command line argument
        if [ -z "$IPINQUESTION" ]
        then
                echo "Usage:  $0 [IP address]"
                exit 1
        fi

        # Debug to see if valid_ip functions works as expected
        #if ! valid_ip $IPINQUESTION;
        #  then
        #    echo "$IPINQUESTION is NOT valid"
        #  else
        #    echo "$IPINQUESTION is valid"
        #fi

        if ! valid_ip $IPINQUESTION;
        then
                echo "$IPINQUESTION is NOT a valid IP address"
                exit 1
        fi
}

function CheckIfPripsIsInstalled() {
        PRIPSPATH=`which prips`
        if [ -z $PRIPSPATH ];
        then
                echo "the prips command isn't found"
                echo "apt install prips"
                exit 1
        fi

} # // CheckIfPripsIsInstalled



################################################
#  __  __       _
# |  \/  | __ _(_)_ __
# | |\/| |/ _` | | '_ \
# | |  | | (_| | | | | |
# |_|  |_|\__,_|_|_| |_|
#
################################################

# Verify if prips is installed
CheckIfPripsIsInstalled


# validate command line input
isvalidinput



# Get URLs to check from whois query
#DEBUG: limit whois data to first entry
#WHOISURL=`whois $IPINQUESTION | grep "^Ref:" | grep entity` | awk '{print $2}' | head -n 1
WHOISURL=`whois $IPINQUESTION | grep "^Ref:" | grep entity | awk '{print $2}'`



# wget each of the ARIN URLs and output the IPs from the resultant data
# trims out ipV6
while IFS= read -r line
do
        #echo $line
        wget --quiet $line --output-document=- | grep -e startAddress -e endAddress | awk '{print $3}' | awk -F'"' '{print $2}' | sed 'N;s/\n/ /' | grep -v ":" >> $TEMPIPLISTFILE
done <<< "$WHOISURL"



# convert start and end address list into CIDR notation
while IFS= read -r line
do
        #echo "$line"
        prips -c $line
done <"$TEMPIPLISTFILE"

rm $TEMPIPLISTFILE

exit 0
