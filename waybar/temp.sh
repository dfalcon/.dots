#!/bin/bash
# temp1_input = "Package id 0" — температура всього кристала.
# Було temp2_input, тобто "Core 0": одне P-ядро, занижує на 4-6 °C
# у простої і сильніше під навантаженням, бо гріється зазвичай інше ядро.
temp=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input)
temp=$((temp / 1000))
if [ "$temp" -ge 90 ]; then cls="critical"
elif [ "$temp" -ge 75 ]; then cls="warning"
else cls="normal"; fi
echo "{\"text\":\"󰔏 ${temp}°C\",\"class\":\"$cls\"}"
