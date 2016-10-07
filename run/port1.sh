#!/bin/sh
cd ..
while true ; do
	./fteqw.sv -game gmapn +exec ports/port1.cfg >> port1.log 2>&1
	sleep 1
done
