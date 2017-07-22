#!/bin/bash

for f in ./run/port*.sh; do
	if [ -f $f ] && [[ $f =~ \./run/port([0-9]+)\.sh ]]; then
		port=${BASH_REMATCH[1]}
		printf "* Starting ftesv (port %s)..." $port
		if ps ax | grep -v grep | grep "fteqw.sv -game cspree -port $port +set port $port" > /dev/null; then
			echo "[ALREADY RUNNING]"
		else
			./run/port$port.sh > /dev/null &
			echo "[OK]"
		fi
	fi
done

qtv=(./run/qtv*.sh)

if [ -f $qtv ] && [[ $qtv =~ \./run/qtv([0-9]+)\.sh ]]; then
	port=${BASH_REMATCH[1]}
	printf "* Starting qtv (port $port)..."
	if ps ax | grep -v grep | grep "qtv.bin +exec qtv.cfg" > /dev/null; then
		echo "[ALREADY RUNNING]"
	else
		./run/qtv$port.sh > /dev/null &
		echo "[OK]"
	fi
fi
