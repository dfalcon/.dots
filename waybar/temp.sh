#!/bin/bash
temp=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp2_input)
temp=$((temp / 1000))
if [ "$temp" -ge 90 ]; then cls="critical"
elif [ "$temp" -ge 75 ]; then cls="warning"
else cls="normal"; fi
echo "{\"text\":\"󰔏 ${temp}°C\",\"class\":\"$cls\"}"
