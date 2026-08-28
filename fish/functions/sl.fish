function sl --description "streamlink в фоне, терминал свободен"
    setsid -f streamlink $argv >/dev/null 2>&1
end
