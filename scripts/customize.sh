#!/bin/bash
# ========================================================
# SWEFTY-OS System Customization Script
# Runs inside rootfs chroot during image build
# ========================================================

set -e  # stop if any command fails

echo "[*] Starting SWEFTY-OS Customization..."

# 1. Set the Hostname
echo "swefty-os" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1   localhost
127.0.1.1   swefty-os
::1         localhost ip6-localhost ip6-loopback
EOF

# 2. Update package lists & install hacker tools
echo "[*] Installing hacker packages and utilities..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
    python3 \
    curl \
    wget \
    git \
    htop \
    btop \
    cmatrix \
    nano \
    micro \
    net-tools \
    iproute2 \
    sudo \
    openssh-server \
    network-manager \
    parted \
    e2fsprogs

# 3. Create default user 'swefty' if it doesn't exist
if ! id "swefty" &>/dev/null; then
    echo "[*] Creating user 'swefty'..."
    useradd -m -s /bin/bash -G sudo,video,audio swefty
    # default password is 'swefty' (user can change later)
    echo "swefty:swefty" | chpasswd
    echo "root:swefty" | chpasswd
fi

# 4. Install our custom swefty Cyberdeck command
echo "[*] Installing /usr/local/bin/swefty..."
if [ -f /tmp/swefty ]; then
    cp /tmp/swefty /usr/local/bin/swefty
    chmod +x /usr/local/bin/swefty
fi

# 5. Enable SSH and NetworkManager services
echo "[*] Enabling system services..."
systemctl enable ssh || true
systemctl enable NetworkManager || true

# 6. Clean up package cache to keep image small
echo "[*] Cleaning up package cache..."
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "[+] SWEFTY-OS customization complete! Ready to boot."