#!/bin/bash

port=27511

while [ -f ./run/port$port.sh ]; do
	timeout=false
	printf "* Stopping ftesv (port %s)..." $port
	pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port$port.sh" | awk '{print $1}'`
	if [ "$pid" != "" ]; then
		count=0
		while kill $pid 2> /dev/null; do
			if [ $count -eq 10 ]; then
				timeout=true
				break
			fi
			sleep 1
			let count=count+1
		done
	fi
	pid=`ps ax | grep -v grep | grep "fteqw.sv -game cspree -port $port +set port $port" | awk '{print $1}'`
	if [ "$pid" != "" ]; then
		count=0
		while kill $pid 2> /dev/null; do
			if [ $count -eq 10 ]; then
				timeout=true
				break
			fi
			sleep 1
			let count=count+1
		done
	fi
	if [ timeout == true ]; then
		echo "[TIMED OUT]"
	else
		echo "[OK]"
	fi
	let port=port+1
done

# Kill QTV
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/qtv.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "qtv.bin +exec qtv.cfg" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
