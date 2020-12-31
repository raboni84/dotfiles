#!/usr/bin/env bash
CWD=$(pwd)
PKG=awesome

pushd srcfiles
git diff > $CWD/$PKG.patch
popd
sed -i "s/^--- a\\//--- $PKG\\//g" $PKG.patch
sed -i "s/^+++ b\\//+++ $PKG\\//g" $PKG.patch
