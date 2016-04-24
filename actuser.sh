#!/bin/bash
#actusr.sh
#Alerts for specific recently active forum user
#actusr.sh v0.2 last edit 28-01-2014 14:45
#
#						TEH COLORZ
########################################################################
STD=$(echo -e "\e[0;0;0m")		#Revert fonts to standard colour/format
RED=$(echo -e "\e[1;31m")		#Alter fonts to red bold
REDN=$(echo -e "\e[0;31m")		#Alter fonts to red normal
GRN=$(echo -e "\e[1;32m")		#Alter fonts to green bold
GRNN=$(echo -e "\e[0;32m")		#Alter fonts to green normal
BLU=$(echo -e "\e[1;36m")		#Alter fonts to blue bold
BLUN=$(echo -e "\e[0;36m")		#Alter fonts to blue normal
#
#						MISC INFO
########################################################################
VERS=$(sed -n 4p $0 | cut -d " " -f 2)	#Version
DATETIME=`date +%d-%m-%Y_%H:%M:%S`
#
#						VARIABLES
########################################################################
TUNE=/usr/share/sounds/freedesktop/stereo/phone-incoming-call.oga
URLINDEX="https://top-hat-sec.com/forum/index.php"
LOC=/root/
VERBOSE=0
SOUND=0
TIME=15
ANY=0
#
#						CREATE SINGLE USER CHECK SCRIPT
########################################################################
f_smf_create () {
DATETIME=`date +%d-%m-%Y_%H:%M`
curl -s $URLINDEX | grep "active in past" > recent_actusr.tmp
MEMBERONLINE=$(grep -o $MEMBERUID recent_actusr.tmp)
if [ "$MEMBERONLINE" == "$MEMBERUID" ] ; then
USR=$(sed -e "s/^.*$MEMBERUID//" -e 's/<\/a>.*$//' -e 's/^.*">//' recent_actusr.tmp)
zenity --info --title="User Activity" --text="User $USR with UID $MEMBERUID recently online" --display=:0.0 --timeout=5
#rm -rf recent_actusr.tmp
exit 0
fi
#rm -rf recent_actusr.tmp
exit 0
}
#
#						CREATE ANY USER CHECK SCRIPT
########################################################################
f_ausr_create () {
DATETIME=`date +%d-%m-%Y_%H:%M`
curl -s $URLINDEX | grep "active in past" > recent_actusr.tmp
MEMBERONLINE=$(grep "profile;u=" recent_actusr.tmp)
if [ "$MEMBERONLINE" != "" ] ; then
USRS=$(sed -e 's/profile;u=/\n/g' recent_actusr.tmp | sed 1d | sed -e 's/^.*">//' -e 's/<\/a>.*$//')
zenity --info --title="User Activity" --text="User(s) recently online \n\n$USRS" --display=:0.0 --timeout=5
rm -rf recent_actusr.tmp
exit 0
fi
rm -rf recent_actusr.tmp
exit 0
}
#
#						DELETE CREATED SCRIPT FUNCTION
########################################################################
f_delete () {
echo $BLU">$BLUN Deleting previously created actusr scripts$STD"
for i in $(ls "$LOC"*_actusr_script.sh) ; do echo $GRN">$STD Removing $GRNN$i$STD" ; rm $i ; done
exit 0
}
#
#						HELP FUNCTION
########################################################################
f_help () {
echo "Alert on recent member activity"
echo $BLUN"
REQUIRED INPUT$STD
Either 
-m <USR ID #>
or
-a $BLUN

OPTIONS$STD
-a  --  Alert for any recently active members
-d  --  Delete created scripts
-h  --  This help information
-l  --  Log file
-m  --  Member USR ID
-o  --  Output directory for created script 
        (default: /root/)
-s  --  Sound alert ON on recent member activity
        (default: OFF)
-t  --  Time interval in minutes between checks
        (default: 15)
-u  --  Forum index URL to check (only SMF forums)
        (default: https://top-hat-sec.com/forum/index.php)
-v  --  Verbose ON (alert when no recent activity)
        (default: OFF)$BLUN

EXAMPLES$STD
./actusr.sh -m 1467
./actusr.sh -m 1467 -t 10 -s -v
./actusr.sh -m 1467 -t 10 -s -v -o /root/scripts/"

exit 0
}
#
#						INPUT OPTIONS
########################################################################
while getopts ":adhl:m:o:st:u:v" opt; do
  case $opt in
	a) ANY=1 ;;
	d) f_delete ;;
	h) f_help ;;
	m) MEMBERUID=$OPTARG ;;
	l) LOG=$OPTARG ;;
	o) LOC=$OPTARG ;;
	s) SOUND=1 ;;
	t) TIME=$OPTARG ;; 
	u) URLINDEX=$OPTARG ;;
	v) VERBOSE=1 ;;
  esac
done
#
#						INPUT CHECKS
########################################################################
if [ -z $URLINDEX ] ; then 
echo $RED">$STD Must enter index url of forum with -u switch"
exit 0
fi

if [ $# -eq 0 ] ; then f_help
elif [[ -z $MEMBERUID && "$ANY" == "0" ]] ; then
echo $RED">$STD Must enter either a user ID number with -m switch or 
  use the -a switch for any member"
exit 0
elif [[ ! -z $MEMBERUID && "$ANY" == "1" ]] ; then 
echo $RED">$STD Use either -m switch or -a switch"
exit 0
fi

#
#						RECAP
########################################################################

echo $BLU">$STD Proceding with script & crontab creation..$STD"
sleep 0.5
#
#						CREATE SCRIPT FOR SPECIFIED USR
########################################################################
if [ "$ANY" == "0" ] ; then
	declare -f f_smf_create > script_actusr.tmp
	sed -i -e 1,2d  -e '$d' script_actusr.tmp
	sed -i '1 s/^.*$/#!\/bin\/bash/' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '11i #' script_actusr.tmp
	sed -i '11i #' script_actusr.tmp
	sed -i '14i #' script_actusr.tmp
	sed -i '14i #' script_actusr.tmp
	sed -i '14i #' script_actusr.tmp	
#
	sed -i "2c URLINDEX=$URLINDEX" script_actusr.tmp	
	sed -i "6c MEMBERUID=$MEMBERUID" script_actusr.tmp
#
if [ "$SOUND" == "1" ] ; then
		sed -i "3c TUNE=$TUNE" script_actusr.tmp
		sed -i "11c paplay $TUNE" script_actusr.tmp
fi
#
if [ ! -z $LOG ] ; then
		sed -i "4c LOG=$LOG" script_actusr.tmp
		sed -i '5c DATETIME=`date +%d-%m-%Y_%H:%M:%S`' script_actusr.tmp
		sed -i '14c echo -n "$DATETIME --> " >> $LOG && echo "$USR" >> $LOG' script_actusr.tmp
fi
if [ "$VERBOSE" == "1" ] ; then
LINES=$(wc -l script_actusr.tmp | awk '{print $1}')
sed -i ""$LINES"i zenity --info --title='User Activity' --text='No recent user activity' --display=:0.0 --timeout=2" script_actusr.tmp
fi
mv script_actusr.tmp $LOC"$MEMBERUID"_actusr_script.sh
sleep 1
echo $GRN">$STD Script$GRNN "$MEMBERUID"_actusr_script.sh$STD created.."
#						CREATE CRONTAB JOB FOR USR SCRIPT
echo "*/$TIME * * * * bash $LOC"$MEMBERUID"_actusr_script.sh" > cron_actusr.tmp
crontab cron_actusr.tmp
sleep 0.5
echo -n $GRN">$STD crontab job:$GRNN "
crontab -l
sleep 0.5
echo "$STD  created on: $GRNN$DATETIME$STD"
sleep 0.5
echo $BLUN"  (to remove crontab job:$GRNN crontab -r"$BLUN")$STD"
rm -rf *_actusr.tmp
#						CREATE SCRIPT FOR ANY USR
elif [ "$ANY" == "1" ] ; then 
	declare -f f_ausr_create > script_actusr.tmp
	sed -i -e 1,2d  -e '$d' script_actusr.tmp
	sed -i '1 s/^.*$/#!\/bin\/bash/' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '2i #' script_actusr.tmp
	sed -i '11i #' script_actusr.tmp
	sed -i '11i #' script_actusr.tmp
	sed -i '14i #' script_actusr.tmp
	sed -i '14i #' script_actusr.tmp
	sed -i '14i #' script_actusr.tmp	
#
	sed -i "2c URLINDEX=$URLINDEX" script_actusr.tmp	
#
	if [ "$SOUND" == "1" ] ; then
		sed -i "3c TUNE=$TUNE" script_actusr.tmp
		sed -i "11c paplay $TUNE" script_actusr.tmp
	fi
#
	if [ ! -z $LOG ] ; then
		sed -i "4c LOG=$LOG" script_actusr.tmp
		sed -i '5c DATETIME=`date +%d-%m-%Y_%H:%M:%S`' script_actusr.tmp
		sed -i '14c echo -e "$DATETIME" >> $LOG  && echo "-------------------" >> $LOG && echo -e "$USRS \n" >> $LOG' script_actusr.tmp
	fi
	if [ "$VERBOSE" == "1" ] ; then
		LINES=$(wc -l script_actusr.tmp | awk '{print $1}')
		sed -i ""$LINES"i zenity --info --title='User Activity' --text='No recent user activity' --display=:0.0 --timeout=2" script_actusr.tmp
	fi	
	mv script_actusr.tmp "$LOC"any_actusr_script.sh
	sleep 0.5
	echo $GRN">$STD Script$GRNN any_actusr_script.sh$STD created.."
#						CREATE CRONTAB JOB FOR USR SCRIPT
echo "*/$TIME * * * * bash "$LOC"any_actusr_script.sh" > cron_actusr.tmp
crontab cron_actusr.tmp
sleep 0.5
echo -n $GRN">$STD crontab job:$GRNN "
crontab -l
sleep 0.5
echo "$STD  created on: $GRNN$DATETIME$STD"
sleep 0.5
echo $BLUN"  (to remove crontab job:$GRNN crontab -r"$BLUN")$STD"
rm -rf *_actusr.tmp
fi

#
#						THE END :)
########################################################################
exit 0
