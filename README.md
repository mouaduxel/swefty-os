# ⚡ SWEFTY-OS

> **A custom Cyberdeck Linux firmware & OS distribution for the Radxa ROCK 2A (Rockchip RK3528) and Raspberry Pi.**  
> Built for **Hack Club // Stardance** by **Mouad**.

```
   ___       __     ______ ________  __      ____  _____
  / _ \_____/ /__  / __/ // /_  __/__\ \    / __ \/ ___/
 / // / _  /  '_/ _\ \/ _  / / / /___/\ \  / /_/ /\__ \ 
/____/\_,_/_/\_\ /___/_//_/ /_/        \_\ \____/____/ 
   >> [ SWEFTY-OS v1.0 // ROCKCHIP RK3528 CYBERDECK ] <<
```

---

## 🚀 Overview

**SWEFTY-OS** is an embedded, terminal-first Linux distribution crafted for cyberdecks, portable hacker rigs, and compact SBC workstations. 

Instead of a generic bloated desktop, SWEFTY-OS boots straight into a lightweight, cyberpunk-styled environment with custom telemetry, hacker toolsets, and system monitors pre-configured out-of-the-box.

---

## 🛠️ Hardware Target

* **Primary Board**: **Radxa ROCK 2A**
  * **SoC**: Rockchip RK3528A Quad-core ARM Cortex-A53 @ 2.0 GHz
  * **GPU**: ARM Mali-450
  * **Architecture**: `aarch64` (ARM64)
  * **Storage**: MicroSD / eMMC
* **Secondary Targets**: Raspberry Pi 3/4/5

---

## ⚡ What We Built (Devlog #1)

1. **`swefty` Cyberdeck Dashboard (`bin/swefty`)**:
   * Custom interactive terminal control center written in Python 3.
   * Real-time hardware telemetry: SoC temperature reading, RAM consumption, root storage, and local IP resolver.
   * Visual cyberpunk ASCII bar graphs and command launcher.
   * Works both on physical ARM64 Linux hardware and local workstations.

2. **Terminal Identity & MOTD (`overlay/etc/motd`)**:
   * Custom boot ASCII banner welcoming users to SWEFTY-OS.
   * Shell branding honoring Hack Club & Stardance.

3. **Cyberpunk Shell Environment (`overlay/etc/profile.d/swefty.sh`)**:
   * Custom multi-color prompt: `⚡ swefty@rock2a:~$ `.
   * Custom aliases for quick system diagnostics (`status`, `ll`, `ports`, `temp`).

4. **RootFS Customization Engine (`scripts/customize.sh`)**:
   * Configures hostname `swefty-os` and `/etc/hosts`.
   * Pre-installs hacker utilities (`micro`, `btop`, `cmatrix`, `net-tools`, `htop`).
   * Sets up default user accounts and systemd services.

---

## 🧪 Testing the Dashboard Locally

You can test the Cyberdeck dashboard right now on any terminal:

```bash
git clone https://github.com/<your-username>/swefty-os.git
cd swefty-os
chmod +x bin/swefty
./bin/swefty
```

---

## 📜 Roadmap

- [x] Cyberdeck CLI & Telemetry Dashboard
- [x] Custom MOTD & Terminal Prompt Theme
- [x] RootFS Customization Script
- [ ] First-boot interactive setup wizard (Wi-Fi / Hostname configuration)
- [ ] GitHub Actions automated cloud build workflow for `.img.xz`
- [ ] Flashable SD Card image release

---

*Made with ⚡ by Mouad for Hack Club Stardance.*
