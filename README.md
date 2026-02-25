# Ubuntu24_04_ROS2_Jazzy
Installing ROS 2 Jazzy on Ubuntu 24.04 alongside Windows 11

**Step 1: Download the Ubuntu 24.04 iso image file from [01].** 

**Step 2: Install Rufus using [02].**

**Step 3: Create a bootable USB stick using Rufus [02].**

**Step 4: Shrink Your Partition (Windows)**

Do not shrink the partition from within Linux if it is your primary Windows C: drive; use Windows Disk Management instead. 
Backup your data: Always back up before partitioning.
Open Disk Management: Press Win + R, type diskmgmt.msc, and hit Enter.
Shrink Volume: Right-click your main partition (usually C:) and select Shrink Volume.
Allocate Space: Type in the amount of space to shrink in MB (e.g., for 100GB, enter 102400, for 200GB, enter 204800).
Reboot: Ensure your bootable Ubuntu 24.04 USB drive is ready.

**Step 5: Boot from the USB flash drive**
Insert the USB stick into the laptop or PC where you want to install Ubuntu.

Restart the computer.

Your device should recognize the installation media and launch the Ubuntu installer.

If Ubuntu doesn’t launch, restart your computer again. This time, hold a key during startup:
On a PC or Windows computer, F12 is the most common key for bringing up the system boot menu but Escape, F2 and F10 are common alternatives. If unsure, look for a brief message when your system starts: this often informs you which key to press to access the boot menu. You can also find the right key in the documentation for your laptop or PC.

In the boot menu that appears, select your USB device.

**Step 6: Follow the installer**

The Ubuntu Desktop installer opens.

References:
[01]. Install Ubuntu Desktop. https://documentation.ubuntu.com/desktop/en/latest/tutorial/install-ubuntu-desktop/
[02]. Rufus. https://rufus.ie/en/
