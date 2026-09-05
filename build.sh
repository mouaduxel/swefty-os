#!/bin/bash
# ========================================================
# SWEFTY-OS Firmware Image Builder for Radxa ROCK 2A
# Target: Rockchip RK3528 / ARM64
# ========================================================

set -e

WORK_DIR="$(pwd)"
OUTPUT_DIR="${WORK_DIR}/output"
BUILD_DIR="${WORK_DIR}/build"
IMAGE_NAME="swefty-os-rock2a-v1.0.img"
MOUNT_DIR="${BUILD_DIR}/mnt"
LOOP_DEV=""

cleanup() {
    echo "[*] Cleaning up temporary mounts..."
    sync || true
    if [ -d "${MOUNT_DIR}" ]; then
        umount -l "${MOUNT_DIR}/dev/pts" 2>/dev/null || true
        umount -l "${MOUNT_DIR}/dev" 2>/dev/null || true
        umount -l "${MOUNT_DIR}/proc" 2>/dev/null || true
        umount -l "${MOUNT_DIR}/sys" 2>/dev/null || true
        umount -l "${MOUNT_DIR}" 2>/dev/null || true
    fi
    if [ -n "${LOOP_DEV}" ]; then
        losetup -d "${LOOP_DEV}" 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo "=== [1/5] Setting up build environment ==="
mkdir -p "${OUTPUT_DIR}" "${BUILD_DIR}" "${MOUNT_DIR}"

# Official Radxa Bookworm release for RK3528 / ROCK 2A
BASE_IMAGE_URL="https://github.com/radxa-build/radxa-rk3528/releases/download/rsdk-r3/radxa-rk3528_bookworm_cli_r3.output_512.img.xz"
BASE_XZ="${BUILD_DIR}/base.img.xz"
BASE_IMG="${BUILD_DIR}/${IMAGE_NAME}"

if [ ! -f "${BASE_IMG}" ]; then
    if [ ! -f "${BASE_XZ}" ]; then
        echo "=== [2/5] Downloading base Radxa RK3528 firmware ==="
        curl -f -L -o "${BASE_XZ}" "${BASE_IMAGE_URL}"
    fi
    echo "=== [3/5] Decompressing base image ==="
    xz -d -k -v "${BASE_XZ}"
    # Identify decompressed file
    EXTRACTED=$(ls "${BUILD_DIR}"/*.img | grep -v "${IMAGE_NAME}" | head -n 1)
    if [ -n "${EXTRACTED}" ]; then
        mv "${EXTRACTED}" "${BASE_IMG}"
    fi
fi

echo "=== [4/5] Mounting image & injecting SWEFTY-OS ==="
LOOP_DEV=$(losetup -Pf --show "${BASE_IMG}")
echo "Loop device allocated: ${LOOP_DEV}"
sleep 2

# Dynamically find the ext4 rootfs partition
ROOT_PART=""
for p in ${LOOP_DEV}p*; do
    if blkid "$p" | grep -q 'TYPE="ext4"'; then
        ROOT_PART="$p"
        break
    fi
done
if [ -z "${ROOT_PART}" ]; then
    ROOT_PART="${LOOP_DEV}p2"
    [ -b "${ROOT_PART}" ] || ROOT_PART="${LOOP_DEV}p1"
fi
echo "Mounting rootfs partition: ${ROOT_PART}"
mount "${ROOT_PART}" "${MOUNT_DIR}"

# Bind mount essential system endpoints for chroot
mount --bind /dev "${MOUNT_DIR}/dev"
mount --bind /dev/pts "${MOUNT_DIR}/dev/pts"
mount -t proc /proc "${MOUNT_DIR}/proc"
mount -t sysfs /sys "${MOUNT_DIR}/sys"
cp /etc/resolv.conf "${MOUNT_DIR}/etc/resolv.conf"

# Copy SWEFTY-OS filesystem overlay
if [ -d "${WORK_DIR}/overlay" ]; then
    echo "[*] Copying overlay files..."
    cp -r "${WORK_DIR}/overlay/"* "${MOUNT_DIR}/"
fi

# Copy swefty CLI
echo "[*] Installing swefty CLI dashboard..."
mkdir -p "${MOUNT_DIR}/usr/local/bin" "${MOUNT_DIR}/tmp"
cp "${WORK_DIR}/bin/swefty" "${MOUNT_DIR}/usr/local/bin/swefty"
cp "${WORK_DIR}/bin/swefty" "${MOUNT_DIR}/tmp/swefty"
chmod +x "${MOUNT_DIR}/usr/local/bin/swefty"
fi

# Copy customize script
cp "${WORK_DIR}/scripts/customize.sh" "${MOUNT_DIR}/tmp/customize.sh"
chmod +x "${MOUNT_DIR}/tmp/customize.sh"

# Enable ARM64 emulation inside chroot
cp /usr/bin/qemu-aarch64-static "${MOUNT_DIR}/usr/bin/" 2>/dev/null || true

echo "=== Executing SWEFTY-OS customization inside chroot ==="
chroot "${MOUNT_DIR}" /bin/bash /tmp/customize.sh

# Cleanup chroot artifacts
rm -f "${MOUNT_DIR}/tmp/customize.sh" "${MOUNT_DIR}/tmp/swefty"
rm -f "${MOUNT_DIR}/usr/bin/qemu-aarch64-static" 2>/dev/null || true

sync
umount -l "${MOUNT_DIR}/dev/pts" 2>/dev/null || true
umount -l "${MOUNT_DIR}/dev" 2>/dev/null || true
umount -l "${MOUNT_DIR}/proc" 2>/dev/null || true
umount -l "${MOUNT_DIR}/sys" 2>/dev/null || true
umount -l "${MOUNT_DIR}" 2>/dev/null || true
losetup -d "${LOOP_DEV}" 2>/dev/null || true
LOOP_DEV=""

echo "=== [5/5] Compressing final bootable image ==="
xz -z -k -T0 -1 "${BASE_IMG}"
mv "${BUILD_DIR}/${IMAGE_NAME}.xz" "${OUTPUT_DIR}/"

echo "=========================================================="
echo " BUILD SUCCESSFUL!"
echo " Flashable image: ${OUTPUT_DIR}/${IMAGE_NAME}.xz"
echo "=========================================================="
