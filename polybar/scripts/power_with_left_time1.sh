#!/usr/bin/env bash

BATTERY_PATH="/sys/class/power_supply/BAT0"
CURRENT_CAPACITY=$(cat $BATTERY_PATH/capacity)
CHARGE_NOW=$(cat $BATTERY_PATH/charge_now)
CURRENT_NOW=$(cat $BATTERY_PATH/current_now)

TIME_LEFT=""

if [[ $CURRENT_NOW -gt 0 && $(cat $BATTERY_PATH/status) != "Charging" ]]; then
  TIME_LEFT=$((CHARGE_NOW / CURRENT_NOW))h
else
  TIME_LEFT=""
fi

echo - | awk "{printf \"%.1f\",                     
$((\
$(cat /sys/class/power_supply/BAT0/current_now) * \
$(cat /sys/class/power_supply/BAT0/voltage_now))) / 1000000000000 }"

if [[ $TIME_LEFT ]]; then
  echo " W | $TIME_LEFT"
else 
  echo " W"
fi
