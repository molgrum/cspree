#!/bin/bash

printf "* Starting ftesv (port 27511)..."
if ps ax | grep -v grep | grep "fteqw.sv -game cspree -port 27511" > /dev/null
then
    echo "[ALREADY RUNNING]"
else
    ./run/port27511.sh > /dev/null &
    echo "[OK]"
fi

printf "* Starting ftesv (port 27512)..."
if ps ax | grep -v grep | grep "fteqw.sv -game cspree -port 27512" > /dev/null
then
    echo "[ALREADY RUNNING]"
else
    ./run/port27512.sh > /dev/null &
    echo "[OK]"
fi

printf "* Starting ftesv (port 27513)..."
if ps ax | grep -v grep | grep "fteqw.sv -game cspree -port 27513" > /dev/null
then
    echo "[ALREADY RUNNING]"
else
    ./run/port27513.sh > /dev/null &
    echo "[OK]"
fi

# UNCOMMENT IF YOU WANT QTV RUNNING HERE

#printf "* Starting qtv (port 28000)..."
#if ps ax | grep -v grep | grep "qtv.bin +exec qtv.cfg" > /dev/null
#then
#    echo "[ALREADY RUNNING]"
#else
#    ./run/qtv.sh > /dev/null &
#    echo "[OK]"
#fi
