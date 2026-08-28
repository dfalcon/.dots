#!/bin/sh
# Уведомления о смене трека в Spotify (у клиента их нет — берём из MPRIS).
cover="${XDG_RUNTIME_DIR:-/tmp}/spotify-cover.jpg"
last=
# stdbuf -oL: в пайпе playerctl буферизует блоками, строки не доходят до цикла
stdbuf -oL playerctl -p spotify --follow metadata \
    --format '{{xesam:title}}|{{xesam:artist}}|{{mpris:artUrl}}' 2>/dev/null |
while IFS='|' read -r title artist art; do
    [ -z "$title" ] && continue
    [ "$title|$artist" = "$last" ] && continue   # spotify шлёт метадату по нескольку раз на трек
    last="$title|$artist"

    icon=spotify
    # ponytail: один фиксированный файл, не кэш — обложка нужна только на время показа
    [ -n "$art" ] && curl -sfL --max-time 3 -o "$cover" "$art" && icon="$cover"

    notify-send -a Spotify -i "$icon" \
        -h string:x-canonical-private-synchronous:spotify \
        "$title" "$artist"
done
