# DOTFILES Setup

[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa] ![project status][status-shield]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[cc-by-nc-sa]: LICENSE
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-informational.svg
[status-shield]: https://img.shields.io/badge/status-active%20development-brightgreen

## [tl;dr] Quickstart on ready-to-run system with empty user (e.g. don't care):

```bash
# only if git is not available
sudo pacman -S git openssh
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare https://github.com/.../dotfiles.git ~/.dotfiles
dotfiles checkout master -f
~/.local/bin/system_setup
```

## [tl;dr] Ready-to-run system with existing user (e.g. many merge, much fun):

```bash
# only if git is not available
sudo pacman -S git
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare https://github.com/.../dotfiles.git ~/.dotfiles
dotfiles checkout master
# begin by checking and preserving differences
# ...
# after that is done, setup the system
~/.local/bin/system_setup
```

## [tl;dr] Fixing an out-of-sync remote on a system with an old version of DOTFILES:

```bash
dotfiles remote set-head origin master
dotfiles fetch --all
dotfiles reset --hard master
~/.local/bin/system_setup
```

## Partitioning

The first step should be booting into your Archlinux setup iso and partitioning the system drive while switching to your matching keyboard map. You need to decide now if you want an encrypted system or an unencrypted one. For a server setup an unencrypted system will not ask for a password to unlock the drive.

```bash
# german keyboard (e.g. "loadkezs deßlatin1ßnodeadkezs")
loadkeys de-latin1-nodeadkeys
# partitioning
fdisk -l # (identify system drive path)
fdisk /dev/[drive]
  g
  n # -> efi partition (don't skip even on legacy booted device: you will put the disk in a newer pc sometime in the future)
  enter
  enter
  +100M
  t
  1 # (type 1: EFI)
  n # -> bios boot partition (legacy boot for grub)
  enter
  enter
  +2M
  t
  enter # (partition 2)
  4 # (type 4: BIOS boot)

# if you want a full disk encryption, use the following setup
  n # -> boot partition
  enter
  enter
  +200M
  n # -> encrypted partition with logical volumes inside
  enter
  enter
  enter

# otherwise use this
  n # -> system partition
  enter
  enter
  +???G # 24G base system + 1.5~2x size in 'G' of RAM for hibernation or small VMs, 0.5x otherwise
  n # -> home partition
  enter
  enter
  enter

# final step
  w # -> write changes to disk

# format the partitions
mkfs.fat -F32 /dev/[drive]1
dd if=/dev/zero of=/dev/[drive]2 bs=1M count=2 # zero out the 2M space of the bios boot partition
mkfs.ext4 /dev/[drive]3

# when using encryption, skip this
  mkfs.ext4 /dev/[drive]4
```

You should now have one of these setups:

 - Encrypted:
   1. /dev/[drive]1 - EFI
   2. /dev/[drive]2 - Bios Boot
   3. /dev/[drive]3 - /boot
   4. /dev/[drive]4 - encrypted
 - Unencrypted:
   1. /dev/[drive]1 - EFI
   2. /dev/[drive]2 - Bios Boot
   3. /dev/[drive]3 - /
   4. /dev/[drive]4 - /home

## Encrypted Partition (skip if not needed)

Create the encryption container on top of the 4th partition.

```bash
# WATCH OUT: After the first reboot later on the keyboard could be back to US layout until the next "mkinitcpio -P" call!!!
cryptsetup luksFormat /dev/[drive]4
cryptsetup open /dev/[drive]4 cryptlvm
```

The encrypted container is now mounted at /dev/mapper/cryptlvm. Let's create the logical volumes.

```bash
pvcreate /dev/mapper/cryptlvm
vgcreate volgrp /dev/mapper/cryptlvm

lvcreate -L ???G volgrp -n root # 24G base system + 1.5~2x size in 'G' of RAM for hibernation or small VMs, 0.5x otherwise
lvcreate -l 100%FREE volgrp -n home

mkfs.ext4 /dev/volgrp/root
mkfs.ext4 /dev/volgrp/home
```

## Filesystems and Swap

After that, mount the system drive and home drive at the right location in the right order (watch out!) while creating a swapfile, then make it permanent.
```bash
# -> when using encryption
# /
mount /dev/volgrp/root /mnt
# /home
mkdir /mnt/home
mount /dev/volgrp/home /mnt/home
# /boot
mkdir /mnt/boot
mount /dev/[drive]3 /mnt/boot

# -> otherwise this
# /
mount /dev/[drive]3 /mnt
# /home
mkdir /mnt/home
mount /dev/[drive]4 /mnt/home

# yes, even on legacy boot -> keep everything future proof
mkdir -p /mnt/boot/EFI
mount /dev/[drive]1 /mnt/boot/EFI
# swap file
mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
unit=$(grep MemTotal /proc/meminfo | awk '{print $3}')
#   factor 2 of the total RAM size when using small VMs with little RAM
  size=$(expr $mem \* 2)
#   factor 1.2 of the total RAM size when using hibernation
  size=$(expr $mem \* 6 / 5 + 1)
#   factor 0.2 otherwise
  size=$(expr $mem / 5 + 1)
dd if=/dev/zero of=/mnt/swapfile bs=1$unit count=$size iflag=fullblock status=progress
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
# fstab file
mkdir /mnt/etc
genfstab -U -p /mnt > /mnt/etc/fstab
```

## Minimum System

Now install the base system while switching the context into the newly created partition. If not done already connect to the internet and update pacman.
```bash
# cable with dhcp should work out of the box - for wifi perform the following steps
iwctl
  device list # replace wlan0 with your network card
  station wlan0 scan
  station wlan0 get-networks # replace SSID with your network SSID to connect to
  station wlan0 connect SSID # enter password
  quit
# next update pacman and install base system
pacman -Syy
# choose all defaults here
pacstrap -i /mnt base
arch-chroot /mnt
pacman -S linux-lts linux-lts-headers linux-firmware nano base-devel dhcpcd \
          grub efibootmgr dosfstools os-prober mtools git sudo openssh lvm2
systemctl enable systemd-networkd systemd-resolved dhcpcd
# for wifi cards install/configure these too
  pacman -S iwd iw
  systemctl enable iwd
# WATCH OUT: After a reboot the keyboard could be back to US layout!!! Put simple passwords here like "toor" first until the DOTFILES setup is finished.
passwd
useradd -m -g users -G wheel [username]
# WATCH OUT: After a reboot the keyboard could be back to US layout!!! Put simple passwords here like "resu" first until the DOTFILES setup is finished.
passwd [username]
EDITOR=nano visudo
# -> uncomment the following line
#    %wheel ALL=(ALL) ALL

# install for legacy boot support
grub-install /dev/[drive] --recheck
# efi install will throw errors on legacy booted devices
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

# when utilizing hibernation -> get the exact location of the swap file's first sector
#  ext:     logical_offset:        physical_offset: length:   expected: flags:
#   0:        0..   32767:     >>> 34816.. <<<   67583:  32768:
filefrag -v /swapfile

# modify mkinitcpio.conf
nano /etc/mkinitcpio.conf
# -> add "resume" to the following list
  HOOKS=(... block resume filesystems ...)
# -> and with encryption the fields "keymap encrypt lvm2" also
  HOOKS=(... keyboard keymap encrypt lvm2 fsck ...)

# rebuild init systems
mkinitcpio -P

# get the encrypted root partition UUID for the next step
lsblk -o NAME,UUID

nano /etc/default/grub
# -> edit/uncomment the following lines
  GRUB_DEFAULT="saved"
  # - acpi_osi tells the BIOS that it is not Windows that asks for power events.
  #   This prevents missing or wrong interpreted power events. In my case when plugging in/out the ac power cable resulted in random keyboard
  #   characters "^@^@^@" and killing of dwm or bash scripts.
  # - when needed, cryptdevice and root tells the kernel which encrypted device to unlock for the root path
  # - when needed, resume and resume_offset are for mobile device hibernation
  GRUB_CMDLINE_LINUX_DEFAULT="[...] acpi_osi=Linux cryptdevice=UUID=[devide UUID]:cryptlvm root=/dev/volgrp/root resume=[/dev/[drive]3 **or** /dev/volgrp/root] resume_offset=[physical_offset from filefrag]"
  GRUB_GFXMODE=800x600x32  # set to a small-ish supported resolution for your screen (remember, every screen can give up sometimes...)
  GRUB_SAVEDEFAULT="true"

grub-mkconfig -o /boot/grub/grub.cfg
```

## Timezones

At this point to keep the german language/keyboard after a reboot we need to perform some configuration steps.
```bash
nano /etc/locale.gen
# -> uncomment the following line
#    de_DE.UTF-8 UTF-8
locale-gen
echo "LANG=de_DE.UTF-8" > /etc/locale.conf
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc --utc
```

## Final Steps

Reboot the system and hope that everything works as expected. WATCH OUT as the encrypted partition password is at this time on a non german keyboard layout with switched yz!!!
```bash
exit
# The next one should throw some errors but that's because we have a live system running. Never use the "-l" option as this lazily removes our system and install mount
umount -a
reboot
```

Log into your fresh Archlinux distribution and continue with configuring the keyboard and network again, but this time as user and with NetworkManager
```bash
# username, password, bash shell and remember on switched yz: "loadkezs deßlatin1ßnodeadkezs"
sudo loadkeys de-latin1-nodeadkeys
# ethernet should work out of the box, for wifi do the following
iwctl
  device list # replace wlan0 with your network card
  station wlan0 scan
  station wlan0 get-networks # replace SSID with your network SSID to connect to
  station wlan0 connect SSID # enter password
  quit
ip addr # verify dhcp
sudo pacman -S libxkbcommon
sudo localectl --no-convert set-keymap de-latin1-nodeadkeys
sudo localectl --no-convert set-x11-keymap de pc105 nodeadkeys
```

Reboot the system again. Finally run the DOTFILES setup for the newly created user.
```bash
# username, password, bash shell
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare https://github.com/.../dotfiles.git ~/.dotfiles
dotfiles checkout master -f
~/.local/bin/system_setup
```

Reboot, change passwords, done, have fun.
