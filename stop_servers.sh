#!/bin/bash

SERVER_BINARY_MATCH="fteqw.sv"
GREP="ps -ef | grep -v 'grep' | grep '${SERVER_BINARY_MATCH}' | awk '{print \$1}' | xargs echo"
GREP="pgrep ${SERVER_BINARY_MATCH}"

stop_servers () {
	PIDS=`$GREP`
	for PID in $PIDS; do
		printf "Stopping PID %s.\n" $PID
		nohup kill $PID > /dev/null 2>&1 &
	done
}

if [ -z "`$GREP`" ]; then
	echo "All servers already stopped."
else
	echo "Stopping servers..."
	stop_servers
	TIMEOUT=10
	while [ $TIMEOUT -gt 0 ]; do
		PIDS=`$GREP`
		if [ -z "`$GREP`" ]; then
			echo "Done."
			TIMEOUT=-1
		else
			stop_servers
			TIMEOUT=`expr $TIMEOUT - 1`
			sleep 1
		fi
	done
	if [ $TIMEOUT -eq 0 ]; then
		echo "Timed out."
	fi
fi

echo "Cleaning up..."
pkill -f -9 'sh .*/start_servers.sh'
pkill -f -9 'sh .*/run_one_port.sh'
