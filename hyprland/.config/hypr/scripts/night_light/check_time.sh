#!/bin/sh

wakeup=$((6 * 60))
sunset=$((20 * 60))
night=$((22 * 60))
range=$((night - sunset))

color_day=6500
color_night=2500
color_range=$((color_day - color_night))

while true; do
	current_time=$(($(date +%s) / 60 - $(date -d "$(date +%F)" +%s) / 60))

	if [ $current_time -ge $wakeup ] && [ $current_time -lt $sunset ]; then
		color_temp=$(printf "%.1f" "$color_day")

	elif [ $current_time -ge $sunset ] && [ $current_time -lt $night ]; then
		percent=$(echo "($current_time - $sunset) / $range" | bc -l)
		color_temp=$(echo "$color_day - $color_range * $percent" | bc -l)
		color_temp=$(printf "%.1f" "$color_temp")

	else
		color_temp=$(printf "%.1f" "$color_night")
	fi

	sed -i "s/temperature = [0-9][0-9][0-9][0-9]\.[0-9]/temperature = $color_temp/" ~/.config/hypr/night_light.glsl

	sleep 60
done
