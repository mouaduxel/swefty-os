#!/bin/bash
# SWEFTY-OS Post-Login Shell & Interface

# Custom Cyberpunk Prompt
export PS1="\[\033[1;35m\]⚡ swefty\[\033[0m\]@\[\033[1;36m\]rock2a\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\] \$ "

# Useful custom aliases
alias status="swefty"
alias ll="ls -lah --color=auto"
alias ports="netstat -tulpn"
alias temp="cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 'No sensor'"

# Auto-launch SWEFTY-OS Dashboard immediately on login
if [ -z "$SWEFTY_ACTIVE" ] && [ -t 0 ]; then
    export SWEFTY_ACTIVE=1
    /usr/local/bin/swefty
fi
