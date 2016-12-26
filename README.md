# Installing Dragora 3 on the Asus Chromebook C201
This repo is a guide on how to install Dragora version 3 on the C201
Chromebook. Some of the things require some GNU/Linux know-how but I will
attempt to make it easy to understand. This will not only help you install
Dragora but should also help you boot your own modified version of Linux or
Linux-libre on the C201. That being said, you should be able to boot any
ARM-supported GNU/Linux distribution with the generic parts of the guide.

# Recommendations
Before I start, there are some recommendations I would like to give. I highly
recommend removing the original BIOS, coreboot, with the
fully-free [libreboot][libreboot-home]. This will not only make the system more
free but it will actually boot slightly fast this way. Plus it removes the
ChromeOS nonsense at startup. This is *not* a guide for libreboot; that is
found [here][libreboot-howto]. I also recommend using Linux-libre instead of
Linux because Linux contains nonfree software blobs. That being said, this guide
will work with Linux but I will be using Linux-libre. If you do decide to use
Linux-libre **make sure to get a USB wireless dongle. There is no support for
the internal wireless card.** I highly recommend the ath9k wireless card beause
they are fully free. They can be found on [ThinkPenguin][think].

[libreboot-home]: https://libreboot.org/
[libreboot-howto]: https://libreboot.org/docs/install/c201.html
[think]: https://www.thinkpenguin.com/catalog/wireless-networking-gnulinux

I also recommend that you install your system on an external source (at least
8GB is good). Just in case things go wrong, you can still use ChromeOS to fix
the issues. Once you've gotten a working external system, you can then install
onto the internal eMMC at your *own risk.*

# Prerequisites
Before you can boot anything, you must do some stuff on ChromeOS. First and
foremost, you are going to want an external media. I used a thumb drive in this
guide but you may use an SD card. It is recommended that you use an 8GB one. You
should also make sure that you have the newest version of ChromeOS on your
system. You probably already do.

**If you installed libreboot on your system, you can skip these steps**

## Enabling Developer Mode
In order to have access to a shell on ChromeOS, you will need to enable
developer mode. You will also need developer mode to enable external booting
and to disable signed kernel verification.

To enable developer mode:
* Hold down the  `ESC` and `refresh` (the circular arrow) keys then power on the
  device.
  * The device will reboot and display a recovery mode screen.
* Press `ctrl + d` to make the system boot into recovery
* **Switching to recovery mode will delete any content/data stored on your
  device**
* Confirm. This can take 10+ minutes. Be patient.

## Enable External Booting
There are technically 2 different ways to enable this feature, however, I will
only show 1 of these ways because it doesn't require any additional
software. You can see the other way [here][debian].

[debian]: https://wiki.debian.org/InstallingDebianOn/Asus/C201#Enabling_USB.2FSD_card_boot

* Boot up the system and login to ChromeOS as *guest*.
* Open the Chrome browser and press `ctrl + alt + t`.
  * This will open `crosh` a terminal-like prompt for the Chrome browser.
* Type `shell` and press enter.
  * You are now in a GNU/Linux shell.
* You must now login as root, to do this, type `sudo -s` and hit enter.
  * If you are prompted for a password, follow [these][reset] steps to reset the
    device. This should fix that issue.
* Now type `crossystem dev_boot_usb=1` and press enter.
  * You have enabled external booting

NOTE: When you reboot the machine, you can press `ctrl + u` to boot off an
external device and `ctrl + d` to boot off the internal eMMC. If you wait 30
seconds (or 3 seconds on libreboot) it will boot off the eMMC.

[reset]: https://support.google.com/chromebook/answer/183084
