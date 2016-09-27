#!/bin/bash

# Kill 28501
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port1.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "fteqw.sv -game gmapn +exec port1.cfg" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;

# Kill 28502
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port2.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "fteqw.sv -game gmapn +exec port2.cfg" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;

# Kill 28503
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port3.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "fteqw.sv -game gmapn +exec port3.cfg" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;

# Kill 28504
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/port4.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "fteqw.sv -game gmapn +exec port4.cfg" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;

# Kill QTV
pid=`ps ax | grep -v grep | grep "/bin/sh ./run/qtv.sh" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
pid=`ps ax | grep -v grep | grep "qtv.bin +exec qtv.cfg" | awk '{print $1}'`
if [ "$pid" != "" ]; then kill -9 $pid; fi;
