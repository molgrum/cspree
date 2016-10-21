#!/bin/sh
while true ; do
    ./fteqw.sv -game spree +exec port4.cfg >> port4.log 2>&1
    sleep 1
done
