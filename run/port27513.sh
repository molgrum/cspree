#!/bin/sh
cd ..
while true ; do
    ./fteqw.sv -game cspree -port 27513 +set port 27513 >> port27513.log 2>&1
    sleep 1
done
