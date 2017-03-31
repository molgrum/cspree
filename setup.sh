#!/bin/bash

printf "Welcome to Chilling Spree's Warmer Setup Wizard.\n"
printf "You will be asked simple questions on how you\n"
printf "want to organize your personal Quakeworld server.\n"
printf "\n"
printf "Choose a maximum amount of ports to create, you\n"
printf "may quit the setup when you feel enough have\n"
printf "been created.\n"
printf "\n"

# i, servername, country, county, city
createport() {
	printf "Modes: darena, dom, hh, ft, king, lms, rover\n"
	printf "Pick ONE mode to associate this port with [ft]: "
	read mode
	if [ -z $mode ]; then
		mode="ft"
	fi
	printf "Do you want to lock this mode to the port? [y]/n: "
	read yn
	if [ -z $yn ]; then
		yn="y"
	fi
	if [ $yn == "y" ]; then
		lockrules=1
	else
		lockrules=0
	fi
	printf "Port number [%d]: " $((27511+$1-1))
	read port
	if [ -z $port ]; then
		port=$((27511+$i-1))
	fi
	printf "Home map [dm3]: "
	read homemap
	if [ -z $homemap ]; then
		homemap="dm3"
	fi

	# Write the config
	FILE=cfgs/ports/port$port.cfg
	printf '// Custom text to show in server browsers\n'               >> $FILE
	printf 'set g_info_hostname "%s"\n\n'                           $2 >> $FILE
	printf '// Optional custom information about location of server\n' >> $FILE
	printf 'set g_info_country  "%s"\n'                             $3 >> $FILE
	printf 'set g_info_state    "%s"\n'                             $4 >> $FILE
	printf 'set g_info_city     "%s"\n\n'                           $5 >> $FILE
	printf '// Eventual forced game mode for this port\n'              >> $FILE
	printf 'set g_game_mode "%s"\n'                                  $mode >> $FILE
	printf 'set g_game_lockrules "%d"\n\n'                      $lockrules >> $FILE
	printf 'alias startmap_dm "map %s"\n'                     $homemap >> $FILE
}

# maxports
createports() {
	printf "Now you will generate hostnames for your\n"
	printf "servers, the format may look like this:\n"
	printf "databur.st Freeze Tag - Nuernberg, Germany - cspree\n"
	printf "Now enter a nickname for your server [cool]/q: "
	read servername
	if [ -z $servername ]; then
		servername="cool"
	elif [ $servername == "q" ]; then
		exit 1
	fi
	printf "Optional country info of server location []/q: "
	read country
	if [ -z $country ]; then
		country=""
	elif [ $country == "q" ]; then
		exit 1
	fi
	printf "Optional state info of server location []/q: "
	read state
	if [ -z $state ]; then
		state=""
	elif [ $state == "q" ]; then
		exit 1
	fi
	printf "Optional city info of server location []/q: "
	read city
	if [ -z $city ]; then
		city=""
	elif [ $city == "q" ]; then
		exit 1
	fi
	for i in `seq 1 $1`; do
		createport $i $servername $country $state $city
	done
}

queryports() {
	printf "Max no of ports [4]: "
	read maxports
	if [ -z $maxports ]; then
		maxports=4
	fi
	printf "%d ports, are you sure? (y/n/q): " $maxports
	read yn
	if [ -z $yn ]; then
		yn="n"
	elif [ $yn == "y" ]; then
		createports $maxports
	elif [ $yn == "n" ]; then
		queryports
	elif [ $yn == "q" ]; then
		exit 0
	fi
}

queryports
