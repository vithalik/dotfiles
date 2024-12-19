#!/usr/bin/env dash

playback_status=$(playerctl status 2>/dev/null)

if [ -n "$playback_status" ]; then

	media=$(playerctl metadata -f "{{artist}} - {{title}}")

	if [ "$playback_status" = "Playing" ]; then
		song_status=''
	elif [ "$playback_status" = "Paused" ]; then
		song_status=''
	fi

	printf "%s" "$song_status $media"
fi
