#!/bin/sh
cd ..
while true ; do
    ./fteqw.sv -game cspree +exec cfgs/ports/port27513.cfg >> port27513.log 2>&1
    sleep 1
done
