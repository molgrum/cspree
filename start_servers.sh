#!/bin/sh

FTEBIN="/home/andreas/quake/fteqw.sv"
BASEDIR="/home/andreas/quake"
MODDIR="/home/andreas/quake/cspree"

if [ -f $FTEBIN ]; then
	for PORT_CFG in $MODDIR/cfgs/ports/port*.cfg; do
		if [ -f $PORT_CFG ]; then # a file
			PORT=`echo $PORT_CFG | tr -d '[A-Za-z\.\/]'`
			printf "* Starting ftesv (port %s)..." $PORT
			PROCESS=`pgrep -f "sh .*/run_one_port.sh ${FTEBIN} ${PORT} ${BASEDIR}"`
			if [ -z "$PROCESS" ]; then
				if [ -z `nohup sh $MODDIR/run/run_one_port.sh $FTEBIN $PORT $BASEDIR > /dev/null 2>&1 &` ]; then
					echo "[OK]"
				else
					echo "[ERROR]"
				fi
			else
				echo "[ALREADY RUNNING]"
			fi
		else
			printf "Port %s seems to be missing a config.\n" $PORT
		fi
	done
else
	echo "Server binary not found."
	exit 1
fi
