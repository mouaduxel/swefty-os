#!/bin/bash
# SWEFTY-OS Terminal Profile & Environment

# Custom Cyberpunk Prompt: [⚡ swefty@rock2a ~/folder ⚡]
export PS1="\[\033[1;35m\]⚡ swefty\[\033[0m\]@\[\033[1;36m\]rock2a\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\] \$ "

# Useful custom aliases
alias status="swefty"
alias ll="ls -lah --color=auto"
alias ports="netstat -tulpn"
alias temp="cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 'No sensor'"

# Print MOTD on interactive shell login
if [ -f /etc/motd ]; then
    cat /etc/motd
fi