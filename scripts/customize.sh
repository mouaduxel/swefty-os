#!/bin/bash
# ========================================================
# SWEFTY-OS System Customization Script
# Runs inside rootfs chroot during image build
# ========================================================

set -e

echo "[*] Starting SWEFTY-OS Customization..."

# 1. Set the Hostname
echo "swefty-os" > /etc/hostname
echo "127.0.0.1   localhost" > /etc/hosts
echo "127.0.1.1   swefty-os" >> /etc/hosts
echo "::1         localhost ip6-localhost ip6-loopback" >> /etc/hosts

# 2. Update package lists & install hacker tools
echo "[*] Installing hacker packages and utilities..."
export DEBIAN_FRONTEND=noninteractive
apt-get update || true
apt-get install -y --no-install-recommends     python3     curl     wget     git     htop     nano     sudo     net-tools     iproute2     openssh-server     network-manager || true

apt-get install -y btop cmatrix micro 2>/dev/null || true

# 3. Create default user "swefty" if it does not exist
if ! id "swefty" &>/dev/null; then
    echo "[*] Creating user swefty..."
    useradd -m -s /bin/bash -G sudo,video,audio swefty || true
    echo "swefty:swefty" | chpasswd || true
    echo "root:swefty" | chpasswd || true
    echo "swefty ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/swefty
    chmod 0440 /etc/sudoers.d/swefty
fi

# 4. Install our custom swefty Cyberdeck command
echo "[*] Installing /usr/local/bin/swefty..."
if [ -f /tmp/swefty ]; then
    cp /tmp/swefty /usr/local/bin/swefty
    chmod +x /usr/local/bin/swefty
fi

# 5. Enable SSH and NetworkManager services
echo "[*] Enabling system services..."
systemctl enable ssh 2>/dev/null || true
systemctl enable NetworkManager 2>/dev/null || true
systemctl enable swefty-issue.service 2>/dev/null || true

# 6. Clean up package cache to keep image small
echo "[*] Cleaning up package cache..."
apt-get clean || true
rm -rf /var/lib/apt/lists/* || true

echo "[+] SWEFTY-OS customization complete! Ready to boot."
