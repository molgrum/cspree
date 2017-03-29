#!/bin/sh
cd ..
while true ; do
    ./fteqw.sv -game cspree +exec cfgs/ports/port27512.cfg >> port27512.log 2>&1
    sleep 1
done
