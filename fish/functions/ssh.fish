function ssh
    if set -q KITTY_WINDOW_ID
        kitten ssh $argv
    else
        command ssh $argv
    end
end
