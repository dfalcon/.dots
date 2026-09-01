#!/usr/bin/env bash
# Перемикач профілю живлення для waybar.
#
# Керуємо через power-profiles-daemon, а НЕ прямим записом EPP.
# Причина (29.08.2026): PPD стоїть у системі з інсталятора EndeavourOS і сам
# перемикає energy_performance_preference при зміні живлення — від'єднав
# зарядку, він поставив balance_power. Ручний запис в EPP він мовчки
# перезаписував, і перемикач показував режим, якого вже немає.
#
# Відповідність профілів PPD і EPP:
#   power-saver -> power / balance_power
#   balanced    -> balance_performance
#   performance -> performance
#
# Використання:
#   power-profile.sh          -> JSON для waybar
#   power-profile.sh toggle   -> наступний профіль по колу

declare -A ICON=(
  [power-saver]="󰌪"   # листок
  [balanced]="󰾅"      # баланс
  [performance]="󰓅"   # спідометр
)
declare -A NAME=(
  [power-saver]="Економія"
  [balanced]="Баланс"
  [performance]="Продуктивність"
)
ORDER=(power-saver balanced performance)

cur() { powerprofilesctl get 2>/dev/null; }

case "${1:-}" in
  toggle)
    c=$(cur)
    next=${ORDER[0]}
    for i in "${!ORDER[@]}"; do
      if [ "${ORDER[$i]}" = "$c" ]; then
        next=${ORDER[$(( (i + 1) % ${#ORDER[@]} ))]}
        break
      fi
    done
    powerprofilesctl set "$next" 2>/dev/null
    pkill -RTMIN+9 waybar 2>/dev/null
    ;;
  *)
    c=$(cur)
    [ -z "$c" ] && { echo '{"text":"󰋗","tooltip":"power-profiles-daemon не відповідає"}'; exit 0; }
    # реальний EPP — корисно бачити, бо PPD міняє його сам
    epp=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null)
    mhz=$(awk '/cpu MHz/{s+=$4; n++} END{if(n) printf "%.0f", s/n}' /proc/cpuinfo)
    temp=$(sensors 2>/dev/null | awk '/Package id 0/{gsub(/[+°C]/,"",$4); print $4; exit}')
    # від мережі чи від батареї
    ac=$(cat /sys/class/power_supply/A*/online 2>/dev/null | head -1)
    src=$([ "$ac" = 1 ] && echo "мережа" || echo "батарея")
    printf '{"text":"%s","class":"%s","tooltip":"Профіль: %s (%s)\\nEPP: %s\\nЧастота: %s МГц · %s°C\\nКлік — наступний"}\n' \
      "${ICON[$c]:-󰋗}" "$c" "${NAME[$c]:-$c}" "$src" "${epp:-?}" "${mhz:-?}" "${temp:-?}"
    ;;
esac
