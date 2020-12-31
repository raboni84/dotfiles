#!/usr/bin/env bash
set -e
set +x

echo \# retrieve the BlackArch Linux keyring
curl -s -O 'https://www.blackarch.org/keyring/blackarch-keyring.pkg.tar.xz'

echo \# make sure /etc/pacman.d/gnupg is usable
sudo pacman-key --init

echo \# install the keyring
sudo pacman --config /dev/null --noconfirm \
    -U blackarch-keyring.pkg.tar.xz
sudo pacman-key --populate

echo \# fetching new mirror list
curl -s -O 'https://www.blackarch.org/blackarch-mirrorlist'
sudo cp blackarch-mirrorlist /etc/pacman.d

echo \# update pacman.conf
sudo patch --forward --strip=1 /etc/pacman.conf "$HOME/.local/build/pacman.blackarch.patch" || true

echo \# enable BlackArch Linux repository
sudo pacman -Syy
