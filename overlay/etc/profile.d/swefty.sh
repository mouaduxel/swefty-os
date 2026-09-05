#!/bin/bash
# SWEFTY-OS Terminal Profile & Environment

# Custom Cyberpunk Prompt: [⚡ swefty@rock2a ~/folder ⚡]
export PS1="\[\033[1;35m\]⚡ swefty\[\033[0m\]@\[\033[1;36m\]rock2a\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\] \$ "

# Useful custom aliases
alias status="swefty"
alias ll="ls -lah --color=auto"
alias ports="netstat -tulpn"
alias temp="cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 'No sensor'"

# Auto-launch SWEFTY-OS Dashboard on the physical HDMI monitor (tty1)
if [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    while true; do
        /usr/local/bin/swefty
        echo -e "\n\033[1;32m[SWEFTY-OS] Reopening dashboard in 2 seconds (or press Enter)... \033[0m"
        read -t 2 -r || true
    done
fi
