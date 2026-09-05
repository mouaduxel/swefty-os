#!/bin/bash
# ========================================================
# SWEFTY-OS Firmware Image Builder for Radxa ROCK 2A
# ========================================================

set -e

WORK_DIR="$(pwd)"
OUTPUT_DIR="${WORK_DIR}/output"
BUILD_DIR="${WORK_DIR}/build"
IMAGE_NAME="swefty-os-rock2a-v1.0.img"

echo "=== [1/5] Setting up build environment ==="
mkdir -p "${OUTPUT_DIR}" "${BUILD_DIR}"

# Base image release for Radxa ROCK 2A (RK3528)
BASE_IMAGE_URL="https://github.com/radxa-build/rock-2a/releases/download/b3/rock-2a_debian_bullseye_cli_b3.img.xz"
BASE_XZ="${BUILD_DIR}/base.img.xz"
BASE_IMG="${BUILD_DIR}/${IMAGE_NAME}"

if [ ! -f "${BASE_IMG}" ]; then
    if [ ! -f "${BASE_XZ}" ]; then
        echo "=== [2/5] Downloading base Radxa ROCK 2A firmware ==="
        curl -L -o "${BASE_XZ}" "${BASE_IMAGE_URL}"
    fi
    echo "=== [3/5] Uncompressing base image ==="
    xz -dk "${BASE_XZ}"
    mv "${BUILD_DIR}/base.img" "${BASE_IMG}"
fi

echo "=== [4/5] Injecting SWEFTY-OS custom files & branding ==="
MOUNT_DIR="${BUILD_DIR}/mnt"
mkdir -p "${MOUNT_DIR}"

# Setup loop device with partition scan
LOOP_DEV=$(losetup -Pf --show "${BASE_IMG}")
echo "Mounted loop device: ${LOOP_DEV}"

# Mount the rootfs partition (partition 2 on Rockchip)
ROOT_PART="${LOOP_DEV}p2"
[ -b "${ROOT_PART}" ] || ROOT_PART="${LOOP_DEV}p1"

mount "${ROOT_PART}" "${MOUNT_DIR}"

# 1. Copy overlay files (motd, profile.d, prompt)
if [ -d "${WORK_DIR}/overlay" ]; then
    cp -r "${WORK_DIR}/overlay/"* "${MOUNT_DIR}/"
fi

# 2. Copy the swefty CLI tool
cp "${WORK_DIR}/bin/swefty" "${MOUNT_DIR}/usr/local/bin/swefty"
chmod +x "${MOUNT_DIR}/usr/local/bin/swefty"

# 3. Copy customization script & run it inside chroot
cp "${WORK_DIR}/scripts/customize.sh" "${MOUNT_DIR}/tmp/customize.sh"
chmod +x "${MOUNT_DIR}/tmp/customize.sh"

echo "=== Running customization inside OS ==="
cp /usr/bin/qemu-aarch64-static "${MOUNT_DIR}/usr/bin/" 2>/dev/null || true

chroot "${MOUNT_DIR}" /bin/bash /tmp/customize.sh

# Cleanup
rm -f "${MOUNT_DIR}/tmp/customize.sh"
rm -f "${MOUNT_DIR}/usr/bin/qemu-aarch64-static" 2>/dev/null || true

sync
umount "${MOUNT_DIR}"
losetup -d "${LOOP_DEV}"

echo "=== [5/5] Compressing final flashable image ==="
xz -z -k -T0 "${BASE_IMG}"
mv "${BUILD_DIR}/${IMAGE_NAME}.xz" "${OUTPUT_DIR}/"

echo "=========================================================="
echo " SUCCESS! Flashable image built at:"
echo " ${OUTPUT_DIR}/${IMAGE_NAME}.xz"
echo " Flash this to an SD card using BalenaEtcher or Pi Imager!"
echo "=========================================================="
