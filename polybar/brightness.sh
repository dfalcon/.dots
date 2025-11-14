#!/bin/bash

OUTPUT="DP-1"
STEP=0.05
STATE_FILE="/tmp/brightness_state"

# Инициализация состояния
if [[ ! -f "$STATE_FILE" ]] || ! grep -qE '^[0-9.]+$' "$STATE_FILE"; then
    echo "1.0" > "$STATE_FILE"
fi

CURRENT=$(cat "$STATE_FILE")

case "$1" in
    up)
        NEW=$(awk -v a="$CURRENT" -v b="$STEP" 'BEGIN {print a + b}')
        ;;
    down)
        NEW=$(awk -v a="$CURRENT" -v b="$STEP" 'BEGIN {print a - b}')
        ;;
    *)
        NEW="$CURRENT"
        ;;
esac

# Ограничиваем диапазон 0.1–1.0
NEW=$(awk -v x="$NEW" 'BEGIN {
    if (x > 1.0) x = 1.0;
    if (x < 0.1) x = 0.1;
    printf "%.2f", x;
}')

echo "$NEW" > "$STATE_FILE"

# Применяем яркость
xrandr --output "$OUTPUT" --brightness "$NEW"

# Перевод в проценты
PERCENT=$(awk -v x="$NEW" 'BEGIN {printf "%d%%", x * 100}')

echo "$PERCENT"
