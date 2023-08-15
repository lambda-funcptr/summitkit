#!/bin/sh

cd $(dirname $0)

qemu-system-x86_64 -enable-kvm -bios /usr/share/ovmf/x64/OVMF.fd -m 4G -drive file=esp.fat
