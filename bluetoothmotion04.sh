#!/bin/bash
#
# Rupert's Bluetooth monitoring progam to turn motion on and off
#

# Note: In order to stop and start motion, and to write to the log file (in the
#     default location), this script must be run as root.
#
# Configuration: Before starting this script, you must edit the MAC varible
#     below to match your cell phone. You can also change the polling interval
#     and the log file location.
#
# Linux installation: Run the following commands from the directory containing
#     this script and the crontab file:
#         sudo cp bt-motion /usr/local/bin
#         sudo chmod 755 /usr/local/bin/bt-motion
#         sudo cp crontab /etc/cron.d/bt-motion
#     If you want to keep the script in a directory other than /usr/local/bin,
#     or if you want to change the polling interval from the default of 5
#     minutes, edit the crontab file.
#
# History:
#     v0.1 March 2009 - Rupert Plumridge (r.plumridge@gmail.com)
#       written with next to no knowledge of bash and loads of googling
#
#     v0.2 March 2009 - Rupert Plumridge (r.plumridge@gmail.com)
#       updated to control motion instead of zoneminder and added a second
#       check before turning it on
# 
#     v0.3 February 2010 - Rupert Plumridge (r.plumridge@gmail.com)
#       updated to work with devices that aren't always discoverable, like most
#       modern smartphones, tested on HTC Hero
# 
#     v0.4 March 2010 - Mike Pelley (mike@pelley.com)
#       expanded comments, removed device name variable


# MAC address of your phone
# Note: If you don't know your MAC address, here is one method to discover it:
#     1. Turn off bluetooth on your phone
#     2. Run "hcitool scan" in a terminal window
#     3. Turn on bluetooth on your phone (must be discoverable)
#     4. Run "hcitool scan" in a second terminal window
#     5. Compare the list between the two windows
#     6. Record MAC address of your phone from second terminal window
MAC="CE:LL:PH:ON:EM:AC"

# Log file
LOGFILE=/var/log/bt-motion.log

# Hostname and scriptname for the log
LOGENTRY="`date '+%b %d %k:%M:%S'` `hostname -s` `basename $0`:"

# Results of bluetooth query for the phone's name (hcitool will return the name
# of the phone if found, and an empty string if not)
NAME="$(hcitool name $MAC)"

# If the phone was not found, start motion (if not running), else stop motion
# (if running)
if [ "$NAME" == "" ]; then
	if ! pgrep -x motion &> /dev/null; then
		echo $LOGENTRY mobile absent, starting motion >> $LOGFILE
		sudo /etc/init.d/motion start
	fi
else 
	if pgrep -x motion &> /dev/null; then
		echo $LOGENTRY mobile $NAME present, stopping motion >> $LOGFILE
		sudo /etc/init.d/motion stop
	fi
fi
