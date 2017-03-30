#!/bin/sh
cd ..
while true ; do
    ./fteqw.sv -game cspree -port 27512 >> port27512.log 2>&1
    sleep 1
done
