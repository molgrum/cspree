#!/bin/bash

port=27511

while [ -f ./run/port$port.sh ]; do
	pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port$port.sh" | awk '{print $1}'`
	if [ "$pid" != "" ]; then kill -9 $pid; fi;
	pid=`ps ax | grep -v grep | grep "fteqw.sv -game cspree -port $port +set port $port" | awk '{print $1}'`
	if [ "$pid" != "" ]; then kill -9 $pid; fi;
	let port=port+1
done

# Kill QTV
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/qtv.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "qtv.bin +exec qtv.cfg" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
