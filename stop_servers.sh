#!/bin/bash

# Kill 27511
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port27511.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "fteqw.sv -game cspree -port 27511" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;

# Kill 27512
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port27512.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "fteqw.sv -game cspree -port 27512" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;

# Kill 27513
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port27513.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "fteqw.sv -game cspree -port 27513" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;

# Kill QTV
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/qtv.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "qtv.bin +exec qtv.cfg" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
