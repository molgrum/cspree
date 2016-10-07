#!/bin/sh
while true ; do
    ./fteqw.sv -game gmapn +exec port3.cfg >> port3.log 2>&1
    sleep 1
done
