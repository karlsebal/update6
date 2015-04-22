#!/bin/sh

echo

warn_pid="echo warning: pid file present!"
warn_run="echo warning: update6 seems to run"
advice="echo you should stop the service before install"


[ -z "$1" ] && action="help" || action="$1"

case "$action" in

  install)
	[ -f /var/run/update6/update6.pid ] && { $warn_pid; $advice; }
	[ -n "$(ps | grep update6 | grep -v grep)" ] && { $warn_run; $advice; }
	cp -i etc/config/update6 /etc/config/
	cp -i etc/init.d/update6 /etc/init.d/
	cp -i usr/bin/update6 /usr/bin/
   ;;

   remove)
	/etc/init.d/update6 stop
	/etc/init.d/update6 disable
	rm /etc/config/update6
	rm /etc/init.d/update6
	rm /usr/bin/update6
   ;;

help)
	echo "usage: $0 {install|remove}"
   ;;

esac

echo

exit 0
