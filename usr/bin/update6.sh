#!/bin/sh

## update freedns domain at afraid.org 

# load config
. /lib/functions.sh

loadSettings() {
	config_get checkInterval "$1" checkInterval
	config_get domain "$1" domain
	config_get updateKey "$1" updateKey
}

config_load update6
config_foreach loadSettings settings

# set command for comfortable logging
log="logger -t update6 "

# extended regex, we call grep -E
ip6regex="([0-9a-f]{0,4}:){2,7}[0-9a-f]{0,4}"

# update forced? set flag if so
[ "$1" = "force" ] && { $log update forced; force=1; } || force=0


# check for running instance

if [ ! -d /var/run/update6 ]; then
	mkdir /var/run/update6
fi

if [ -e /var/run/update6/update6.pid ]; then
	pid=$(cat /var/run/update6/update6.pid)
	rm /var/run/update6/update6.pid
	kill $pid 2>/dev/null
	$log killed running instance
fi

# we are clean now. letz stop here if requested
[ "$1" = "stop" ] && exit;

# okay, new PID
echo "$$" > /var/run/update6/update6.pid


get_current() {
	current6addr=$(ip -6 addr show eth0.2 | grep global\ dynamic | grep -oE "$ip6regex")
}

get_registered() {
	# dots in grepdomain need to be escaped
	grepdomain=$(echo "$domain" | sed 's:\.:\\\.:g')

	# fetch lookup
	lookup=$(nslookup "$domain" 2>/dev/null | grep -A5 "Name:.*$grepdomain")
	
	# extract ipv6address
	registered6addr=$(echo "$lookup" | grep -oE "$ip6regex")
	
	if [ -z "$registered6addr" ]; then
		registered6addr="error"
		$log "ERROR: something went wrong while looking up $domain"
	fi
}

create_url() {
	updateURL="http://freedns.afraid.org/dynamic/update.php?$updateKey&address=$current6addr"
}

create_call() {
	create_url
	call="curl $updateURL"
}


while [ true ]; do
	
	get_current
	get_registered


	if [ $force -ne 0 ] || [ "$current6addr" != "$registered6addr" ]; then
		create_call
		$log "updating $domain to $current6addr"
		$log curl: $($call 2>/dev/null)
	else
		$log "No change. No update."
	fi

	sleep $checkInterval
done
