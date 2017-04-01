#!/bin/bash

port=27511

while [ -f ./run/port$port.sh ]; do
	printf "* Starting ftesv (port %s)..." $port
	if ps ax | grep -v grep | grep "fteqw.sv -game cspree -port $port +set port $port" > /dev/null; then
		echo "[ALREADY RUNNING]"
	else
		./run/port$port.sh > /dev/null &
		echo "[OK]"
	fi
	let port=port+1
done

# UNCOMMENT IF YOU WANT QTV RUNNING HERE

#printf "* Starting qtv (port 28000)..."
#if ps ax | grep -v grep | grep "qtv.bin +exec qtv.cfg" > /dev/null
#then
#    echo "[ALREADY RUNNING]"
#else
#    ./run/qtv.sh > /dev/null &
#    echo "[OK]"
#fi
