#!/bin/sh

warn_pid="echo -e \nwarning: pid file present!"
warn_run="echo -e \nwarning: update6 seems to run"
advice="echo -e you should stop the service before install\n"


[ -z "$1" ] && action="help" || action="$1"

case "$action" in

  install)
	[ -f /var/run/update6/update6.pid ] && { $warn_pid; $advice; exit; }
	[ -n "$(ps | grep update6 | grep -v grep)" ] && { $warn_run; $advice; exit; }
	cp -i etc/config/update6 /etc/config/
	cp -i etc/init.d/update6 /etc/init.d/
	cp -i etc/hotplug.d/iface/25-update6
	cp -i usr/bin/update6 /usr/bin/
   ;;

   remove)
	/etc/init.d/update6 stop
	/etc/init.d/update6 disable
	rm /etc/hotplug.d/iface/25-update6
	rm /etc/config/update6
	rm /etc/init.d/update6
	rm /usr/bin/update6
   ;;

help)
	echo "usage: $0 {install|remove}"
   ;;

esac

exit 0
