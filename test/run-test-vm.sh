#!/bin/sh

cd $(dirname $0)

qemu-system-x86_64 -kernel kernel.img -initrd initramfs.img -append 'rootfstype=ramfs console=ttyS0 rdinit=/sbin/init' -m 4G
