#!/bin/bash
# github.com/webpods/scripts/
# Apache Logs checker for cPanel
# by Webpods, LLC (Robert Taylor)
# cyber@webpods.com
#####################
# Command line usage: 
# alogs -s <HHMM> : Start time 
# alogs -e <HHMM> : End time 
# alogs -u <username> 
# alogs -g <string> : Grep for... 
# alogs -r : rolled logs too 
# alogs -v : verbose mode (multiply the number of results by 5) 
# alogs -d : how many days ago (1 for yesterday, 2 for day before etc) 
# alogs -h : this help

version="1.3.1"

IFS=$'\n'
set -u

# set up functions for binary conversion of IPs and subnet masks
function maskip()
{
    ip=""
    ip=$(echo "${1}" | awk '{print substr($0,0,'"$2"')}')
    echo "${ip:0}"
}

function convip()
{
    CONV=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
    ip=""
    for byte in $(echo "${1}" | tr "." "\n"); do
        ip="${ip}${CONV[${byte}]}"
    done
    echo "${ip:0}"
}
 

# functions to sanity check times dates usernames etc

function timesanity()
{
sanetimeformat=0
sanetimelimit=0
sanetimepast=0
sanetimebefore=0
if ! [[ "$startpoint" =~ ^[0-9]{4}$ ]] || ! [[ "$endpoint" =~ ^[0-9]{4}$ ]]
    then
        echo "Error: times must be formatted as four digits, i.e. HHMM"
        echo
        sanetimeformat=0
    else
        sanetimeformat=1
fi

if [ $sanetimeformat = 1 ]
then
  if (($((10#$startpoint)) > 2359)) || (($((10#$endpoint)) > 2359))
      then
          echo "Error: Times above 2359 do not exist, please check and retry"
          echo
          sanetimelimit=0
      else
          sanetimelimit=1
  fi
fi

if [ $sanetimeformat = 1 ]
then 
  if [ "$daysago" = 0 ] && (($((10#$startpoint)) > $((10#$now))))
      then
          echo "Error: The start time you have entered is in the future - Maybe check the server's timezone?"
          echo "The server timezone is $tzonename ($tzoneoffset) and it is currently $now"
          echo
          sanetimepast=0
      else
          sanetimepast=1
  fi
fi

if [ $sanetimeformat = 1 ]
then
  if (($((10#$startpoint)) > $((10#$endpoint))))
    then
        echo "Error: The start time you have entered is after the end time, so it won't work."
        echo
        sanetimebefore=0
    else
        sanetimebefore=1
  fi
fi

sanetime=$((10#$sanetimeformat+10#$sanetimelimit+10#$sanetimepast+10#$sanetimebefore))
}

function usersanity()
{
userlist=$(cut -d: -f1 /etc/passwd)
if [[ "$username" != "all" ]] && ! [[ $userlist == *"$username"* ]]
    then
        echo "Error: username does not exist"
        echo
        sanetime=0
    else
        saneuser=1
fi
}

# check the load isn't too high

cpus=$(nproc)
echo "cpus = $cpus"
load=$(awk '{print $1}' /proc/loadavg | sed 's/\.//g')
load=$((10#$load))
echo "load = $load%"
loadpercpu=$(( load / cpus ))
echo "load per cpu = $loadpercpu%"
if [ "$loadpercpu" -gt 150 ]
    then
        read -r -e -p "Load looks like it is pretty high, would you like to enable High Load Mode? (takes longer, increases load less) [y/N]:" wanthighloadmode
        wanthighloadmode=${wanthighloadmode:-n}
        if [ "$wanthighloadmode" = y ]
            then
                highloadmode="y"
            else
                highloadmode="n"
        fi
    else
        highloadmode="n"
fi

echo
echo

today=$(date +%d/%b/%Y)
commandline="alogs"
tzonename=$(date +%Z)
tzoneoffset=$(date +%z)
now=$(date +%H%M)
tenminsago=$(date -d "10 minutes ago" +%H%M)
echo "The server timezone is $tzonename ($tzoneoffset) and it is currently $now"
echo

# ask all the questions - only called if not using command line options

function questiontime(){
    read -r -e -p "Would you like to see all the options? (press Enter to continue with the defaults - all accounts for the past 10 minutes) [y/N]: " alloptions
    alloptions=${alloptions:-n}
    echo
    
    if [ "$alloptions" = y ]
      then  
      
        #set variables for while loops
        saneuser=0
        sanetime=0
        currentdir=$(pwd)
        cd /home/ || return
        while [ $saneuser = 0 ]
        do
          read -r -e -p "Enter the username [all]: " username
          username=${username:-all}
          username=$(sed "s/\///1" <<< "$username")
          echo
          usersanity
        done
        commandline="$commandline -u $username"
        cd "$currentdir" || return
        
        while [ $sanetime -lt 4 ]
        do
          read -r -e -p "What time do you want to start at? (Format HHMM) [Leave blank for 10 mins ago]: " startpoint
          startpoint=${startpoint:-"$tenminsago"}
          echo

          now=$(date +%H%M)
          read -r -e -p "What time do you want to finish at? (Format HHMM) [Leave blank for current time]: " endpoint
          endpoint=${endpoint:-"$now"}
          echo

          read -r -e -p "How many days back would you like to go? (Format 1=yesterday, 2=day before yesterday etc...) [Leave blank for today]: " daysago
          daysago=${daysago:-0}
          echo
          
          timesanity
        done
        
        commandline="$commandline -s $startpoint -e $endpoint"
        commandline="$commandline -d $daysago"
        
        if [ "$daysago" = 0 ]
        then 
            read -r -e -p "Would you like to search rolled logs? (Note: Takes longer, causes higher load!) [y/N]: " searchrolled
            searchrolled=${searchrolled:-n}
            echo
            commandline="$commandline -r $searchrolled"
        fi

        read -r -e -p "Would you like to enable verbose mode? (up to 5 times more results) [y/N]: " verbosemode
        verbosemode=${verbosemode:-n}
        echo
        commandline="$commandline -v $verbosemode"

        read -r -e -p "Please enter an additional string to filter for [Leave blank]: " grepfilter
        grepfilter=${grepfilter:-[0-9]} #if no string will match any line with a number in it soa ll get through
        echo
        if [ "$grepfilter" != "[0-9]" ]
        then
            commandline="$commandline -g $grepfilter"
        fi
      else
        username="all"
        startpoint="$tenminsago"
        endpoint="$now"
        searchrolled="n"
        grepfilter="[0-9]"
        verbosemode="n"
        daysago="0"
    fi
}

#show help if requested

function showhelp(){
    echo -e "Command line usage: \n\
        -s <HHMM> : Start time \n\
        -e <HHMM> : End time \n\
        -u <username> \n\
        -g <string> : Grep for... \n\
        -r : rolled logs too \n\
        -v : verbose mode (multiply the number of results by 5) \n\
        -d : how many days ago (1 for yesterday, 2 for day before etc) \n\
        -h : this help\n\n"
}

# parse the command line options if given

function parseopts(){
    username="all"
    startpoint="$tenminsago"
    endpoint="$now"
    searchrolled="n"
    grepfilter="[0-9]"
    verbosemode="n"
    daysago="0"

    while getopts rhvs:e:u:g:d: thisoption
    do
        case "$thisoption" in
         h)
            showhelp
            exit 0;
         ;;
         s)
            startpoint="${OPTARG}"
         ;;
         e)
            endpoint="${OPTARG}"
         ;;
         u)
            username="${OPTARG}"
         ;;
         g)
            grepfilter="${OPTARG}"
         ;;
         v)
            verbosemode="y"
         ;;
         r)
            searchrolled="y"
         ;;
         d)
            daysago="${OPTARG}"
            if [ "$daysago" != "0" ]
                then
                searchrolled="y"
            fi      
        ;;  
        *)
            echo "Unknown argument"
            showhelp
            exit 0
        ;;
        esac
    done
}

# choose whether to ask the questions or parse the command line options

if ( ! getopts rhvs:e:u:g:d: thisoption )
  then
    questiontime
  else
    sanetime=0
    saneuser=0
    parseopts "$@"
    usersanity
    timesanity
    if [ $sanetime -lt 4 ]
    then
        showhelp
        exit 0
    fi
    if [ $saneuser = 0 ]
    then
        showhelp
        exit 0
    fi
fi

# do the sums for verbose mode

if [ "$verbosemode" = y ]
    then
        tailmultiplier="5"
    else
        tailmultiplier="1"
fi

useragenttail=$((tailmultiplier*20))
iptail=$((tailmultiplier*10))
rangetail=$((tailmultiplier*5))

# reconfigure the date if searching previous days

if [ "$daysago" != 0 ]
    then
        today=$(date -d "$daysago days ago" +%d/%b/%Y)
        searchrolled="y"
fi

# echo "startpoint=$startpoint endpoint=$endpoint username=$username grepfilter=$grepfilter searchrolled=$searchrolled verbosemode=$verbosemode daysago=$daysago"
echo "================================================================="
echo "Checking logs for $today from $startpoint to $endpoint $tzonename ($tzoneoffset) for username: $username"
echo "Rolled logs = $searchrolled"
echo "Verbose mode = $verbosemode"
if [ "$grepfilter" != "[0-9]" ]
    then
        echo "Grepping for $grepfilter"
fi
echo "================================================================="

# turn the main variables into numbers by forcing them into base 10

startpoint=$((10#$startpoint))
endpoint=$((10#$endpoint))
now=$((10#$now))

echo
echo -n "Progress ."

if [ "$username" = all ]
then # start wildcard search
    for dirname in /usr/local/apache/logs/domlogs/* # loop round all access logs
    do
        echo -n "."
        rawdata+=$(grep -H "$today" "$dirname"/* 2>/dev/null | grep "$grepfilter" | awk -F: '{if(($3$4)+0 >= '$startpoint' && ($3$4)+0 <= '$endpoint') print $0}')
        if [ "$highloadmode" = y ]
        then
            sleep 5
            echo -n "+"
        fi
    done
    if [ "$searchrolled" = y ]
    then
        for zdirname in /home/*/logs
        do
            echo -n "."
            rawdata+=$(zgrep -H "$today" "$zdirname"/* 2>/dev/null | grep "$grepfilter" | awk -F: '{if(($3$4)+0 >= '$startpoint' && ($3$4)+0 <= '$endpoint') print $0}')
            if [ "$highloadmode" = y ]
            then
                sleep 5
                echo -n "+"
            fi
        done
    fi
else # start single user search
    rawdata=$(grep -H "$today" /home/"$username"/access-logs/* 2>/dev/null | grep "$grepfilter" | awk -F: '{if(($3$4)+0 >= '$startpoint' && ($3$4)+0 <= '$endpoint') print $0}')
    if [ "$searchrolled" = y ]
    then
        echo -n "."
        rawdata+=$(zgrep -H "$today" /home/"$username"/logs/* 2>/dev/null | grep "$grepfilter" | awk -F: '{if(($3$4)+0 >= '$startpoint' && ($3$4)+0 <= '$endpoint') print $0}')
        if [ "$loadpercpu" -gt 150 ]
        then
            sleep 5
            echo -n "+"
        fi
    fi
fi

uagents=$(echo "$rawdata" | awk -F\" '{print $6}' | sort | uniq -c | sort -n | tail -n $useragenttail) # grab the user agent strings, clean themup and sort them out, tail last 20

echo
echo
echo Top "$useragenttail" User Agents In Logs # tail the logs for user agents
echo "=========================="
echo
echo "$uagents" # output list of user agents to screen
echo

liveconnections=$(netstat -nt | grep -E ':80|:443' | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq) # grab netstat connections for comparison in a bit

echo "Top $iptail IP Addresses In Logs (Please note that IPv6 may indicate Cloudflare)" # tail the logs for IP addresses
echo "==========================================================================="
echo

ips=$(echo "$rawdata"  | awk '{print $1}' | awk -F: '{print $2}' | grep '[0-9]' | sort | uniq -c | sort -n | tail -n "$iptail") # grab the IP addresses clean them upand sort them out, then tail the last 10

# get the countries from the IP
for ipitem in $ips # uses end of line as separator between items
do
    ipbare=$(echo "$ipitem" | awk '{print $2}') # grabs the ip address
    if [ -f "/usr/bin/geoiplookup" ]
    then
        ipwhois=$(geoiplookup "$ipbare") # grab the whois for the bare ip address
    else
        ipwhois="Country blank blank Install geoiplookup" # inform that geoiplookup is not there
    fi

    ipcountrycode=$(echo "$ipwhois" | grep -m 1 "Country"| awk -F: '{print $2}') # Grab country data
    iplive="" # set to blank before entering next bit
    ipowner=$(echo "$ipwhois" | grep -m 1 "ASNum") # Grab network owner data if available
    for liveitem in $liveconnections # start comparing ips to the live connections from earlier
    do
        if [ "$liveitem" = "$ipbare" ] # if the IP address is in the list of live connections
        then
            iplive='\033[0;93mLIVE CONNECTION\033[0m'
        fi
    done

    echo -e "$ipitem - $ipcountrycode - $ipowner - $iplive"
done
echo

echo "Top $rangetail IP Ranges (Assumes /24) In Logs"
echo "====================================="
echo

liveranges=$(echo "$liveconnections" | grep '[0-9]' | awk -F "." '{print $1 "." $2 "." $3 ".0"}') #strip the netstat IPs back to ranges

ranges=$(echo "$rawdata" | awk '{print $1}' | awk -F: '{print $2}' | awk -F "." '{print $1 "." $2 "." $3 ".0"}' | grep '[0-9]' | sort | uniq -c | sort -n | tail -n "$rangetail") # grab the IP addresses combine into /24 ranges before sorting

# get the countries from the IP
for rangeitem in $ranges # uses end of line as separator between items
do
    rangebare=$(echo "$rangeitem" | awk '{print $2}') # grabs the ip address
    if [ -f "/usr/bin/geoiplookup" ]
    then
        rangewhois=$(geoiplookup "$rangebare") # grab the geoiplocation data
    else
        rangewhois="Country blank blank Install geoiplookup" # inform that geoiplookup is not there
    fi
    rangelive="" # set to blank before entering next bit
    rangecountrycode=$(echo "$rangewhois" | grep -m 1 "Country"| awk -F: '{print $2}') # only take first country entry on grep
    rangeowner=$(echo "$rangewhois" | grep -m 1 "ASNum") # Grab network owner data if available
    
    for liverangeitem in $liveranges
    do
        if [ "$liverangeitem" = "$rangebare" ] #if the IP range is in the list of live connections
        then
            rangelive='\033[0;93mLIVE CONNECTION\033[0m'
        fi
    done

    echo -e "$rangeitem - $rangecountrycode - $rangeowner - $rangelive" # put them all back together again
done
echo

echo "Top 10 Busiest Sites"
echo "===================="

busysites=$(echo "$rawdata" | awk -F'[/:]' '{print $5}' | sed s/"-ssl_log"//g |sort | uniq -c | sort -n | tail -n 10) # combine log filenames as estimation for which site it is

echo
echo "$busysites"
echo
# generate command for further tailing
if [ "$username" = all ]
then # wildcard command
    command='tail -f /home/*/access-logs/* | grep -E "wp-admin|wp-login|POST|xmlrpc /"'
else # single user command
    command='tail -f /home/'$username'/access-logs/* | grep -E "wp-admin|wp-login|POST|xmlrpc.php /"'
fi
echo "To continue tailing the logs for common attacks, run:   $command"
echo
if [ "$commandline" != "alogs" ]
then
    echo "You just ran: ./$commandline"
    echo
fi

