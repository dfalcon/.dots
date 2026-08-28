#!/usr/bin/env bash

# Город (можно: Kyiv, Lviv, Odessa или auto для автоопределения)
CITY="kharkiv"

# Таймаут, чтобы polybar не зависал
WEATHER=$(timeout 10 curl -s "https://wttr.in/${CITY}?format=%c+%t+%w")

# Если пусто — показать заглушку
if [ -z "$WEATHER" ]; then
    echo " N/A"
else
    echo "$WEATHER"
fi
