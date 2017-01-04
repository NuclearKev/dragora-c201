# Installing Dragora 3 on the Asus Chromebook C201
This repo is a guide on how to install Dragora version 3 on the C201
Chromebook. Some of the things require some GNU/Linux know-how but I will
attempt to make it easy to understand. This will not only help you install
Dragora but should also help you boot your own modified version of
Linux/Linux-libre or any ARM-supported GNU/Linux distributions on the C201.

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
onto the internal eMMC at your *own risk* for it hasn't been tested yet.

# Prerequisites
Before you can boot anything, you must do some stuff on ChromeOS. First and
foremost, you are going to want an external media. I used a thumb drive in this
guide but you may use an SD card. It is recommended that you use an 8GB one
because this guide assumes you are using one. You should also make sure that you
have the newest version of ChromeOS on your system but you probably already do.

**If you installed libreboot on your system, you can skip all prerequisites!**

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

# Installing Dragora ARM onto an External Media
**NOTE: From this point on, things may be different if you wish to install a
different GNU/Linux distribution.**

Plug in the media you wish to install Dragora on in the device. You must now
partition the media with 2 partitions: kernel and root. However, we must use GPT
for our partitioning scheme. **Make sure that you change the device (/dev/sdX or
/dev/mmcblk1X) to the appropriate value. I used a thumb drive and my media was
under the name /dev/sda. If you use an SD card, you will have something like
/dev/mmcblk1.**

* Start by creating a new GPT table like so: `# fdisk /dev/sda`
  * Then type `g` and press enter. This will create a new GPT table on the
    media.
  * Now type `w` and press enter to write the data to the media.

* Obtain `cgpt` either from your package manager or steal it from ChromeOS like
so:
```
# mount -o ro /dev/mmcblk0p3 /mnt
# cp /mnt/usr/bin/cgpt /usr/bin
# umount /mnt
```
* Now we can create the GPT scheme with:
```
# cgpt create /dev/sda
```
* Create a kernel partition with:
```
# cgpt add -i 1 -t kernel -b 8192 -s 32768 -l Kernel -S 1 -T 5 -P 10 /dev/sda
```
* Run the command
```# cgpt show /dev/sda```
  * It will print out something like this:
  ```
  localhost / # cgpt show /dev/sda
       start        size    part  contents
           0           1          PMBR
           1           1          Pri GPT header
        8192       32768      1   Label: "Kernel"
                                  Type: ChromeOS kernel
                                  UUID: E3DA8325-83E1-2C43-BA9D-8B29EFFA5BC4
                                  Attr: priority=10 tries=5 successful=1

    15633375          32          Sec GPT table
    15633407           1          Sec GPT header
	```
  * Take the *start number* from the GPT table sector (in this example, it's
    15633375) and subtract 40960 from it. In my case, that's 15592415. Take that
    number and replace it where the "xxxxxx" is in this command:
	```
	# cgpt add -i 2 -t data -b 40960 -s xxxxxx -l Root /dev/sda
	```
	This will create a root partition that will fill up the rest of the device.
  * NOTE: I have yet to test have multiple partitions such as /tmp, /boot, etc.
* Now that you have both partitions made it's time to populate them. Format your
  second partition to ext4:
  ```
  # mkfs.ext4 /dev/sda2
  ```
* Extract the rootfs tarball onto our external media. Let us
  go somewhere safe:
  ```
  # cd /tmp
  ```
  * While here create a new directory to mount our media:
  ```
  # mkdir root
  ```
  * Download the tarball:
  ```
  # wget http://dragora.org/dragora3/arm/dragora-arm-3.0.0-rootfs.tar.lz
  ```
  * Mount your media to the temporary directory:
  ```
  # mount /dev/sda2 root
  ```
  * Finally, unpack the tarball into the temporary directory:
  ```
  # tar -xf dragora-arm-3.0.0-rootfs.tar.lz -C root
  ```
* You have a very minimal version of Dragora 3 installed to the media now.

# Flashing the Kernel
By the time these instruction are found on Dragora's site, we will have the
kinks worked out. As of now, the instructions for flashing the kernel would
theoretically be like this:

* Run the following command to flash the kernel to the kernel partition:
```
# dd if=root/boot/vmlinux.kpart of=/dev/sda1
```
* **NOTE: Remember to change /dev/sda1 to the appropriate value for your
  device!**
* Unmount the device:
```
# umount root
```
* Sync the system for good measure:
```
# sync
```

At this point you should have a working Dragora 3 install. Before rebooting the
system, read through the next few sections for some more information and
possible issues you may run into. If you don't want to read anymore, reboot the
system and happy hacking!

# Booting with Linux-libre
Let me guess, you tried to boot your new fully-free system and it didn't
work. You got stuck at a white screen. This is actually a good thing! This is
currently one of the major bugs with using Linux-libre
(see [Bugs](#bugs)). This bug is super annoying and will probably take you
forever to get past it. Try the following:

* Power off the device.
* Unplug all external devices. (SD Card and thumb drives)
* Reset the system by holding the `refresh` and `power` keys.
  * The system will reboot and the screen will turn off quickly. Note that the
    power LED will remain on as long as you hold the `power` key.
* Plug in the media you wish to boot off and power on the device.
  * You should get "stuck" on the white screen again. Wait approximately 2-3
    minutes and hopefully it will boot.
  * If it doesn't boot, try these steps again. It may take a couple (it took me
    4-5) tries until the system boots.

# Creating a Bootable Kernel
There are a few things you're going to need in order to create your own
Linux-libre binary. I'll explain this just in case I don't update to the version
that you wish to use. This will give you the freedom to choose whatever version
of Linux-libre you want! Firstly, you will need a copy of Linux-libre, whether
from source or just binary forms. **If you choose the binary forms, make sure
that there is AT LEAST a vmlinuz or zImage AND dtbs directory.** You will need
them!  If you choose to compile from source be sure to do `make ${MAKEFLAGS}
zImage modules dtbs` to create the dtbs directory and the zImage file.

Once you have a the necessary items from the kernel itself, you will need to get
a hold of a few items.
* `vbutil_kernel`
  * This program will create signed kernels for you to boot.
  * It can be [obtained](#obtaining-vbutil_kernel) from the default ChromeOS
    install on the eMMC or from your package manager usually under the name
    `vboot-utils`.
* `mkimage`
  * This will make the image for `vbutil_kernel` to sign.
* All the items in this repo
  * `kernel.keyblock` and `kernel_data_key.vbprivk` for kernel signing
  * `config.txt` for proper booting
  * `kernel.its` to create the correct image for the C201 (may need modified)
  * `make-c201-kernel.sh` to make it all work

Once you've collected all of the programs and files listed you can run the
`make-c201-kernel.sh` script and it should create a kernel that you can copy to
the kernel partition of your external media. **Make sure to double check that
everything is correct for your system and device before running it!** Simply run
`# dd if=newkernel of=/dev/${kernel-partition}` replacing `${kernel-partition}`
with the correct partition.

## Obtaining vbutil_kernel
As mentioned, you can obtain this program by installing a package usually called
`vboot-utils`. However, I imagine that you don't have this program nor care
about it enough to try and build it for Dragora. Luckily, you can easily get it
by copying it from ChromeOS. While on an externally booted system just do the
following:
```
# mount -o ro /dev/mmcblk0p3 /mnt
# cp /mnt/usr/bin/vbutil_kernel /usr/bin
# rsync -a /mnt/usr/share/vboot /usr/share
# umount /mnt
```
The second to last step will give you access to those kernel signing files
from before (`kernel.keyblock` and `kernel_data_key.vbprivk`). It is also a good
idea to obtain `dump_kernel_config` for dumping the command line, not the kernel
config. It makes more sense to use this when scripting. Obtain it like this:
```
# cp /mnt/usr/bin/dump_kernel_config /usr/bin
```

# Installing to the eMMC (NOT TESTED)
As the header suggests, this section is purely theoretical and hasn't been
tested yet. According to [Debian][emmc], installing onto the eMMC requires you
to simply copy everything off your external media. Boot on your external media
and follow these steps to do so:
* Start by shrinking the ROOT-A and ROOT-B partitions:
```
# cgpt add -i 3 -s 32 /dev/mmcblk0
# cgpt add -i 5 -s 32 /dev/mmcblk0
```
* Expand the STATE partition:
```
# cgpt add -i 1 -b 282688 -s 30470080 /dev/mmcblk0
```
* Reformat the partition to ext4:
```
mkfs.ext4 /dev/mmcblk0p1
```
* Copy everything on your external media (be patient, this will take a while):
```
# mount -t ext4 /dev/mmcblk0p1 /mnt
# cp -ax / /mnt
# umount /mnt
```
* According to Debian, you need to reconfigure the kernel. I'm not sure if this
  is actually necessary, thus, I won't put it here yet.
* Flash your kernel to the eMMC's kernel partition:
```
# dd if=/mnt/boot/yourkernel of=/dev/mmcblk0p2
```
* Also according to Debian, you also should set the priorities of the kernel
  partitions:
  ```
  # cgpt add -i 2 -P 10 -S 1 /dev/mmcblk0
  # cgpt add -i 4 -P 0 -S 0 /dev/mmcblk0
  ```

In theory, you should now be able to boot off the eMMC onto your new Dragora
system!

[emmc]: https://wiki.debian.org/InstallingDebianOn/Asus/C201#Installing_to_internal_memory_from_SD_card

# Bugs
* White screen booting issue
  * See [Booting with Linux-libre](#booting-with-linux-libre) for information.
* No eMMC recognition.
  * Debian has a fix for this, however, I haven't got it working
    yet.

# Sources
* https://archlinuxarm.org/platforms/armv7/rockchip/asus-chromebook-flip-c100p#installation
* https://wiki.debian.org/InstallingDebianOn/Asus/C201
* https://plus.google.com/+OlofJohansson/posts/34PYU79eUqP
* https://www.chromium.org/chromium-os/developer-information-for-chrome-os-devices/custom-firmware
* Some dude from freenode #parabola
