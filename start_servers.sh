#!/bin/bash

printf "* Starting ftesv (port 28501)..."
if ps ax | grep -v grep | grep "fteqw.sv -game cspree +exec ports/port1.cfg" > /dev/null
then
    echo "[ALREADY RUNNING]"
else
    ./run/port1.sh > /dev/null &
    echo "[OK]"
fi

#printf "* Starting ftesv (port 28502)..."
#if ps ax | grep -v grep | grep "fteqw.sv -game cspree +exec ports/port2.cfg" > /dev/null
#then
#    echo "[ALREADY RUNNING]"
#else
#    ./run/port2.sh > /dev/null &
#    echo "[OK]"
#fi

#printf "* Starting ftesv (port 28503)..."
#if ps ax | grep -v grep | grep "fteqw.sv -game cspree +exec ports/port3.cfg" > /dev/null
#then
#    echo "[ALREADY RUNNING]"
#else
#    ./run/port3.sh > /dev/null &
#    echo "[OK]"
#fi

#printf "* Starting ftesv (port 28504)..."
#if ps ax | grep -v grep | grep "fteqw.sv -game cspree +exec ports/port4.cfg" > /dev/null
#then
#    echo "[ALREADY RUNNING]"
#else
#    ./run/port4.sh > /dev/null &
#    echo "[OK]"
#fi

#printf "* Starting qtv (port 28000)..."
#if ps ax | grep -v grep | grep "qtv.bin +exec qtv.cfg" > /dev/null
#then
#    echo "[ALREADY RUNNING]"
#else
#    ./run/qtv.sh > /dev/null &
#    echo "[OK]"
#fi
