#!/bin/bash

## Copyright (C) 2016 Kevin Bloom <kdb4@openmailbox.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Commentary:
#
# This script will take the hastle out of creating your own kernel to boot on
# the C201. Keep in mind that you will need to modify this script for whatever
# version you wish to use.
#
# NOTE: If you uncomment the last command, make sure you put in the correct
# kernel partition for whatever device you're using.

# Generate the new image
mkimage -D "-I dts -O dtb -p 2048" -f kernel.its kernel.itb

# Sign the new image and apply the necessary parameters
vbutil_kernel --pack newkernel \
							--keyblock kernel.keyblock \
							--version 1 \
							--signprivate kernel_data_key.vbprivk \
							--bootloader config.txt --config config.txt \
							--vmlinuz kernel.itb --arch arm

# dd if=newkernel of=/dev/sda1
