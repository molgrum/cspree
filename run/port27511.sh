#!/bin/sh
cd ..
while true ; do
	./fteqw.sv -game cspree +exec cfgs/ports/port27511.cfg >> port27511.log 2>&1
	sleep 1
done
