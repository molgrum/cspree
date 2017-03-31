#!/bin/sh
cd ..
while true ; do
	./fteqw.sv -game cspree -port 27511 +set port 27511 >> port27511.log 2>&1
	sleep 1
done
