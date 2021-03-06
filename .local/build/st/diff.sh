#!/usr/bin/env bash
CWD=$(pwd)
PKG=st

pushd srcfiles
git diff > $CWD/$PKG.patch
popd
sed -i "s/^--- a\\//--- $PKG\\//g" $PKG.patch
sed -i "s/^+++ b\\//+++ $PKG\\//g" $PKG.patch
