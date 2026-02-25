# Ubuntu 24.04 + ROS 2 Jazzy alongside Windows 11

A complete guide and helper scripts for setting up a **dual-boot** system with Ubuntu 24.04 LTS and Windows 11, then installing **ROS 2 Jazzy Jalisco**.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Prepare Windows 11 for Dual Boot](#2-prepare-windows-11-for-dual-boot)
3. [Create a Bootable Ubuntu 24.04 USB](#3-create-a-bootable-ubuntu-2404-usb)
4. [Install Ubuntu 24.04 Alongside Windows 11](#4-install-ubuntu-2404-alongside-windows-11)
5. [Post-Installation Ubuntu Setup](#5-post-installation-ubuntu-setup)
6. [Install ROS 2 Jazzy Jalisco](#6-install-ros-2-jazzy-jalisco)
7. [Verify the Installation](#7-verify-the-installation)
8. [Useful ROS 2 Commands](#8-useful-ros-2-commands)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU       | 64-bit dual-core 2 GHz | Quad-core 2 GHz or faster |
| RAM       | 4 GB    | 8 GB or more |
| Disk      | 25 GB free (for Ubuntu) | 50 GB+ free |
| USB Drive | 8 GB    | 16 GB        |
| Internet  | Required during install | — |

### Software Requirements

- A running **Windows 11** system
- A USB flash drive (≥ 8 GB) that can be erased
- [Rufus](https://rufus.ie) (Windows) or [balenaEtcher](https://www.balena.io/etcher/) to write the ISO
- [Ubuntu 24.04 LTS ISO](https://releases.ubuntu.com/24.04/)

> **Note:** ROS 2 Jazzy Jalisco officially supports **Ubuntu 24.04 (Noble Numbat)**. Make sure you download the correct Ubuntu release.

---

## 2. Prepare Windows 11 for Dual Boot

### 2.1 Back Up Your Data

Before modifying disk partitions, **back up all important files** on your Windows drive.

### 2.2 Disable Fast Startup

Fast Startup keeps the Windows partition in a partially hibernated state, which can cause filesystem corruption when accessed from Linux.

1. Open **Control Panel → Power Options → Choose what the power buttons do**.
2. Click **Change settings that are currently unavailable**.
3. **Uncheck** *Turn on fast startup (recommended)*.
4. Click **Save changes**.

### 2.3 Disable Secure Boot (if needed)

Some systems require Secure Boot to be disabled to boot Ubuntu. Ubuntu 24.04 ships with signed bootloaders, so this is often unnecessary, but if you cannot boot from the USB:

1. Restart and enter your firmware/UEFI settings (commonly **F2**, **F10**, **F12**, or **Del** during POST).
2. Navigate to the **Security** or **Boot** tab.
3. Set **Secure Boot** to **Disabled**.
4. Save and exit.

### 2.4 Free Up Disk Space for Ubuntu

1. Press **Win + X** → **Disk Management**.
2. Right-click your Windows partition (usually `C:`) → **Shrink Volume**.
3. Enter the amount to shrink (e.g., `51200` MB for 50 GB).
4. Click **Shrink**.

You will now have unallocated space available for Ubuntu.

---

## 3. Create a Bootable Ubuntu 24.04 USB

### Using Rufus (Windows)

1. Download [Rufus](https://rufus.ie) and open it.
2. Under **Device**, select your USB drive.
3. Click **SELECT** and choose the downloaded `ubuntu-24.04-desktop-amd64.iso`.
4. Leave the default settings (GPT partition scheme, UEFI).
5. Click **START** and confirm when prompted.

### Using balenaEtcher (cross-platform)

1. Download and open [balenaEtcher](https://www.balena.io/etcher/).
2. Click **Flash from file** and select the Ubuntu ISO.
3. Click **Select target** and choose your USB drive.
4. Click **Flash!** and wait for completion.

---

## 4. Install Ubuntu 24.04 Alongside Windows 11

1. Insert the bootable USB drive and restart your PC.
2. Enter the boot menu (commonly **F12** or **F11**) and select the USB drive.
3. Choose **Try or Install Ubuntu**.
4. Select your language and click **Install Ubuntu**.
5. Choose your keyboard layout and click **Next**.
6. Select **Normal installation** (or Minimal) and ensure both network options are checked.
7. On the **Installation type** screen, choose **Install Ubuntu alongside Windows Boot Manager**.
   - If this option does not appear, choose **Something else** and manually assign the unallocated space.
8. Follow the on-screen prompts (timezone, user account).
9. Click **Install Now** and confirm the partition changes.
10. After installation, remove the USB drive and reboot.

> **GRUB** will now appear at every boot, letting you choose between Ubuntu and Windows 11.

---

## 5. Post-Installation Ubuntu Setup

Boot into Ubuntu 24.04 and run the following commands to update the system:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl gnupg lsb-release software-properties-common
```

---

## 6. Install ROS 2 Jazzy Jalisco

You can use the provided helper script or follow the manual steps below.

### Option A — Automated Script

```bash
# Clone this repository (if you haven't already)
git clone https://github.com/narsimlukemsaram/Ubuntu24_04__ROS2_Jazzy.git
cd Ubuntu24_04__ROS2_Jazzy

# Make the script executable and run it
chmod +x install_ros2_jazzy.sh
./install_ros2_jazzy.sh
```

### Option B — Manual Steps

#### 6.1 Set the Locale

```bash
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
```

#### 6.2 Enable the Universe Repository

```bash
sudo apt install -y software-properties-common
sudo add-apt-repository universe
```

#### 6.3 Add the ROS 2 GPG Key and Repository

```bash
sudo apt update && sudo apt install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    https://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
    sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```

#### 6.4 Install ROS 2 Jazzy

```bash
sudo apt update
sudo apt upgrade -y

# Desktop install (recommended): includes RViz, demos, tutorials
sudo apt install -y ros-jazzy-desktop

# OR Base install (headless / embedded systems):
# sudo apt install -y ros-jazzy-ros-base

# Developer tools (optional but recommended)
sudo apt install -y ros-dev-tools
```

#### 6.5 Source the ROS 2 Setup Script

Add the source command to your shell configuration so it is loaded automatically:

```bash
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

## 7. Verify the Installation

Open two terminal windows and run the following commands to confirm ROS 2 is working correctly.

### Terminal 1 — Start the talker demo

```bash
source /opt/ros/jazzy/setup.bash
ros2 run demo_nodes_cpp talker
```

### Terminal 2 — Start the listener demo

```bash
source /opt/ros/jazzy/setup.bash
ros2 run demo_nodes_cpp listener
```

You should see the talker publishing messages and the listener receiving them:

```
[INFO] [talker]: Publishing: 'Hello World: 1'
[INFO] [listener]: I heard: [Hello World: 1]
```

### Check the ROS 2 Version

```bash
ros2 --version
# Expected output: ros2, version X.X.X (Jazzy Jalisco)
```

---

## 8. Useful ROS 2 Commands

| Command | Description |
|---------|-------------|
| `ros2 topic list` | List all active topics |
| `ros2 topic echo <topic>` | Print messages on a topic |
| `ros2 node list` | List all running nodes |
| `ros2 node info <node>` | Show node details |
| `ros2 pkg list` | List installed packages |
| `ros2 run <pkg> <executable>` | Run a node |
| `ros2 launch <pkg> <launch_file>` | Launch a launch file |
| `rviz2` | Open RViz2 visualiser |
| `rqt` | Open rqt GUI tool suite |

---

## 9. Troubleshooting

### GRUB does not appear at boot

- Enter the UEFI boot menu (usually **F12**) and manually select **ubuntu**.
- Inside Ubuntu, run `sudo update-grub` to regenerate the GRUB configuration.

### Ubuntu cannot connect to the internet

```bash
sudo dhclient
# or
nmcli networking on
```

### `ros2` command not found after installation

Ensure you have sourced the setup file:

```bash
source /opt/ros/jazzy/setup.bash
```

Add it permanently:

```bash
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### ROS 2 packages cannot be found (`apt` errors)

Re-add the ROS 2 repository and update:

```bash
sudo apt update
sudo apt install -y ros-jazzy-desktop
```

### Windows clock shows wrong time after booting Ubuntu

Ubuntu uses UTC for the hardware clock; Windows uses local time. Fix this in Ubuntu:

```bash
sudo timedatectl set-local-rtc 1 --adjust-system-clock
```

---

## License

This project is licensed under the [MIT License](LICENSE).
