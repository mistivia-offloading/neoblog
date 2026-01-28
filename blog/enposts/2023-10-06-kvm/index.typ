// qemu-kvm Notes
#import "/template-en.typ":*
#doc-template(
title: "qemu-kvm Notes",
date: "October 6, 2023",
body: [

= Preparation

Ignore MSRS, see:

- #link("https://wiki.archlinux.org/title/QEMU#Certain_Windows_games/applications_crashing/causing_a_bluescreen")[Certain Windows games/applications crashing/causing a bluescreen - ArchLinux Wiki]

Run:

```
sudo modprobe kvm; echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs
```

Also add to `/etc/modprobe.d/kvm.conf`:

```
options kvm ignore_msrs=1
```

Permission configuration:

```
sudo usermod -aG kvm $(whoami)
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG input $(whoami)
```

= Creating a Virtual Machine

First, create a disk image:

```
qemu-img create -f qcow2 os.qcow2 256G
```

Then prepare the installation disk image, such as Windows 10 or Ubuntu. Assume the installation disk is `install.iso`. Then create a startup script `start.sh`:

```
#!/bin/bash

chipset="type=q35,kernel_irqchip=on,mem-merge=on"
vcpu="host"
hyper="kvm,thread=multi"
CPU_SOCKETS="1"
CPU_CORES="2"
CPU_THREADS="2"
MEM=4096

qemu-system-x86_64 \
    -enable-kvm \
    -m "${MEM}" \
    -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check \
    -machine ${chipset} \
    -cpu ${vcpu} \
    -device ich9-ahci,id=sata \
    -smp "${CPU_THREADS}",cores="${CPU_CORES}",sockets="${CPU_SOCKETS}" \
    -drive id=HDD,if=none,file="./os.qcow2",format=qcow2 \
    -device ide-hd,bus=sata.3,drive=HDD \
    -netdev user,id=net0,hostfwd=tcp::8022-:22 \
    -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
    -usb  \
    -device usb-tablet \
    -device qemu-xhci,id=xhci \
    -vga virtio \
    -vnc :0 \
    -cdrom ./install.iso
    #-usb -device usb-host,hostbus=1,hostaddr=4
```

After completing the installation, you can comment out the `cdrom` line.

= Connecting USB External Devices

Use `lsusb` to query the bus number and device number of the port, and then use the last line to connect into the virtual machine. At this time, it needs to be run with `sudo` permissions.

I was not successful with the audio configuration, but using an external USB sound card and then connecting via USB works.

])
