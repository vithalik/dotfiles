#!/usr/bin/env dash

case $1 in
"shutdown")
	rm ~/.cache/cliphist/db && halt -p
	;;
"reboot")
	reboot
	;;
"logout")
	hyprctl dispatch exit
	;;
esac

printf "shutdown\nreboot\nlogout"
