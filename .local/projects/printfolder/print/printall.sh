#!/usr/bin/env bash

if mkdir /print/lock
then
    sleep 1
    for filename in /print/monitor/*.pdf; do
        fuser "$filename" || (lp "$filename" && mv "$filename" /print/done/)
    done
    rmdir /print/lock
fi