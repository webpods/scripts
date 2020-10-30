#!/bin/bash
#
# Detect and temporarily block flood
# based on SYN_RECV / (TIME_WAIT(1/2) states) <- disabled ;p
#
# NOTE:
# - list of temp banned IPs: banned_ips.txt
#
# - file for whitelisting IPs: whitelist.txt (one per line)
#   note: once IP is added to whitelist.txt it will be auto unbanned
#         next time the session runs (see sleep_time= below)
#
# if you get message as below:
# /var/run/block-flood.lock present - another instance already running!
#
# make sure the script isn't already running (ps aux|grep block-flood)
# then delete /var/run/block-flood.lock
#
# to unblock everything and reset timed bans list, run: ./unblock
# (doesn't affect whitelist.txt)
#
# added recv_cnt which only bans the IP address if it hits recv_cnt
# ban time (hours)
ban_expire=2

# ban ip after how many syn_recv counts
recv_cnt=100

# delay between sessions (minutes)
sleep_time=3

# directory with script, timed bans list, etc.
work_dir=/root/block-flood

# remove lock on SIGINT (ctrl+c)
function remove_lock() {
        echo -ne "\nremoving lockfile.." && rm -vf ${lock_file}
        exit 0
}

function unblock_whitelisted() {
	cnt_white_unban=0

	${bin_ip} route show|grep ^blackhole|awk '{print $2}' >._tmp_blackhole_list
	while read -r curr_white; do

		white_blocked=$(grep -q "^${curr_white}$" ${work_dir}/._tmp_blackhole_list;echo $?)
		if [[ ${white_blocked} -eq 0 ]]; then
			if [[ ${dry} -eq 0 ]]; then ${bin_ip} route del blackhole ${curr_white}; fi
			let cnt_white_unban+=1
		fi
	done <<< "$(cat ${work_dir}/whitelist.txt)"
}

function unblock_expired() {
	cnt_expired=0
	while read -r c_entry; do

		ep_now=$(date +%s)

		bl_time=$(echo ${c_entry}|awk '{print $1}')
		bl_host=$(echo ${c_entry}|awk '{print $2}')

		ban_age=$(expr ${ep_now} - ${bl_time})

		if [[ ${ban_age} -gt ${ban_expire_secs} ]]; then
			#echo "debug: c_entry: ${c_entry}"
			#echo "debug: ban expired for ${bl_host} (ban_age: ${ban_age}, ban_timeout: ${ban_expire_secs})"
			queue_expired+=( ${bl_host} )
			let cnt_expired+=1

		fi

	done <<< "$(cat ${work_dir}/banned_ips.txt)"

	if [[ ! -z ${queue_expired[@]} ]]; then

		while read -r queue_entry; do

			sed -i "/ ${queue_entry}$/d" ${work_dir}/banned_ips.txt
			if [[ ${dry} -eq 0 ]]; then ${bin_ip} route del blackhole ${queue_entry}; fi
		done <<< "$(echo ${queue_expired[@]}|sed 's/ /\n/g')"
	fi
}


# Generate list of IPs to block, remove whitelisted and already banned IPs
function generate_blocklist() {

	# whitelist IPs listed in whitelist.txt file
	whitelist_xtra_ips=($(cat ${work_dir}/whitelist.txt))

	# server's own IPs + whitelist.txt
	whitelist=$(${bin_ip} -4 a|grep -oP '(?<=inet\s)\d+(\.\d+){3}';echo ${whitelist_xtra_ips[@]}|sed 's/ /\n/g')

	# [ /root/netstat-tables (nt, time_w) ]
	# dump participating IPs
	${bin_nt} -pena|grep "^tcp\s"|grep SYN_RECV|grep "::" -v|awk '{print $5}'|cut -d':' -f1|sort|uniq -c|awk -v x=$recv_cnt '$1 >= x'|awk '{print $2}' > \
		${work_dir}/bad_ips

	while read -r filter_ip; do

		sed -i "/^${filter_ip}$/d" ${work_dir}/bad_ips

	done <<< "${whitelist}"

	# returns ready to use 'bad_ips' list
	while read -r filter_existing; do

		chk_existing=$(grep -q "^${filter_existing}$" ${work_dir}/bad_ips;echo $?)

		if [[ ! ${chk_existing} -gt 0 ]]; then

			sed -i "/^${filter_existing}$/d" ${work_dir}/bad_ips

		fi
	done <<< "$(awk '{print $2}' ${work_dir}/banned_ips.txt)"
	num_bad=$(cat ${work_dir}/bad_ips|wc -l)
}


function block_ips() {

	cnt_block_ip=$(cat ${work_dir}/bad_ips|wc -l)

	while read -r ban_current_ip; do

		if [[ ${dry} -eq 0 ]]; then ${bin_ip} route add blackhole ${ban_current_ip}; fi
		echo "$(date +%s) ${ban_current_ip}" >>${work_dir}/banned_ips.txt

	done <<< "$(cat ${work_dir}/bad_ips)"
#	rm -f ${work_dir}/bad_ips
}

## main

lock_file=/var/run/block-flood.lock

# call on ctrl+c
trap remove_lock SIGINT

# dry run if 'noblock' option specified
extra_arg="$1"
if [[ "${extra_arg}" = "noblock" ]]; then dry=1; else dry=0; fi

#Comment out for starting with init/systemd
#echo "started. logging to /var/log/block-flood.log, executing every ${sleep_time} mins"

# prevent from running another instance
if [[ -f ${lock_file} ]]; then
	echo "${lock_file} present - another instance already running!"
	exit 1
fi

while [[ -true ]] ;do
  touch ${lock_file}

  ban_expire_secs=$(expr ${ban_expire} \* 3600)
  #ban_expire_secs=120  # debug

  bin_ip=$(which 2>/dev/null ip)
  bin_nt=$(which 2>/dev/null netstat)

  if [[ -z ${bin_ip} ]] || [[ -z ${bin_nt} ]]; then
	echo "missing ip/netstat tool, exiting"; exit 1
  fi

  cnt_syn_recv=$(${bin_nt} -pena|grep "^tcp\s"|grep SYN_RECV|wc -l)

  top_5=$(${bin_nt} -pena|grep "^tcp\s"|grep SYN_RECV|grep "::" -v|awk '{print $5}'|cut -d':' -f1|sort|uniq -c|sort -n|tail -5|sort -nr)

  unblock_whitelisted
  if [[ ${cnt_white_unban} -gt 0 ]]; then
	echo "$(date '+%d-%m-%Y %T %Z')  -  [whitelist] - unbanned ${cnt_white_unban} IP(s) found in whitelist.txt" >>/var/log/block-flood.log
  fi

  if [[ ${cnt_syn_recv} -gt 10 ]]; then

	echo "$(date '+%d-%m-%Y %T %Z')  -  [sess_start]" >>/var/log/block-flood.log

	num_banned=$(cat ${work_dir}/banned_ips.txt|wc -l)
	if [[ ${num_banned} -gt 0 ]]; then
		unblock_expired
		  if [[ ${cnt_expired} -gt 0 ]]; then
			echo "$(date '+%d-%m-%Y %T %Z')  -  [expired] - unbanned ${cnt_expired} IP(s)" >>/var/log/block-flood.log
		  fi
	fi

	generate_blocklist

	if [[ ${num_bad} -gt 0 ]]; then
		block_ips
		  if [[ ${cnt_block_ip} -gt 0 ]]; then
			echo "$(date '+%d-%m-%Y %T %Z')  -  [banned] - ${cnt_block_ip} IP(s) has been blocked" >>/var/log/block-flood.log
		  fi
	fi
	echo "$(date '+%d-%m-%Y %T %Z')  -  [sess_end]" >>/var/log/block-flood.log
  fi

  sleep ${sleep_time}m
done
