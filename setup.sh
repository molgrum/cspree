#!/bin/bash

printf "Welcome to Chilling Spree's Server Setup Wizard.\n"
printf "You will be asked simple questions on how you\n"
printf "want to organize your personal Quakeworld server.\n"
printf "\n"
printf "Choose a maximum amount of ports to create, you\n"
printf "may quit the setup when you feel enough have\n"
printf "been created.\n"
printf "\n"

createrun() {
	FILE=run/port$port.sh
	printf 'Writing %s...\n' $FILE
	mkdir -p "$(dirname "$FILE")"
	touch "$FILE"
	printf '#!/bin/sh\n'                                                    > $FILE
	printf 'cd ..\n'                                                       >> $FILE
	printf 'while true ; do\n'                                             >> $FILE
	printf '	./fteqw.sv -game cspree'                               >> $FILE
	printf ' -port %s +set port %s >> port%s.log 2>&1\n' $port $port $port >> $FILE
	printf '	sleep 1\n'                                             >> $FILE
	printf 'done\n'                                                        >> $FILE
	printf 'Setting permissions...\n'
	chmod +x $FILE
}

# i, servername, country, county, city
createport() {
	printf "\nNew port for %s\n\n" "$servername"
	printf "Modes: various, freeze, darena, lms, headhunt, dom, king, rover\n"
	printf "Pick at least ONE 'various' port, the rest are recommended to be picked in the order above [various]: "
	read mode
	if [ -z "$mode" ]; then
		mode="various"
	fi
	printf "Do you want to lock this mode to the port? y/[n]: "
	read yn
	if [ -z "$yn" ]; then
		yn="n"
	fi
	if [ "$yn" = "y" ]; then
		lockrules=1
	else
		lockrules=0
	fi
	printf "Port number [%d]: " $((27511+$1-1))
	read port
	if [ -z "$port" ]; then
		port=$((27511+$i-1))
	fi
	printf "Home map [dm3]: "
	read homemap
	if [ -z "$homemap" ]; then
		homemap="dm3"
	fi
	printf "Bot skill (0-4) [0]: "
	read skill
	if [ -z "$skill" ]; then
		skill="0"
	fi

	# Write the config
	FILE=cfgs/ports/port$port.cfg
	printf 'Writing %s...\n' $FILE
	mkdir -p "$(dirname "$FILE")"
	touch "$FILE"
	printf '// Custom text to show in server browsers\n'                > $FILE
	printf 'set g_info_hostname "%s"\n\n'                         "$2" >> $FILE
	printf '// Optional custom information about location of server\n' >> $FILE
	printf 'set g_info_country  "%s"\n'                           "$3" >> $FILE
	printf 'set g_info_state    "%s"\n'                           "$4" >> $FILE
	printf 'set g_info_city     "%s"\n\n'                         "$5" >> $FILE
	printf '// Optional forced game mode for this port\n'              >> $FILE
	printf 'set g_game_botskill "%s"\n'                       "$skill" >> $FILE
	printf 'set g_game_mode "%s"\n'                            "$mode" >> $FILE
	printf 'set g_game_lockrules "%d"\n\n'                "$lockrules" >> $FILE
	printf 'alias startmap_dm "map %s"\n'                   "$homemap" >> $FILE
	createrun "$port"
}

# maxports
createports() {
	printf "\nNow you will generate hostnames for your\n"
	printf "servers, the format may look like this:\n"
	printf "quake1.de Freeze Tag - Nuernberg, Germany\n"
	printf "Now enter a nickname for your server [unnamed.com]/q: "
	read servername
	if [ -z "$servername" ]; then
		servername="unnamed.com"
	elif [ "$servername" = "q" ]; then
		exit 0
	fi
	printf "Optional country info of server location []/q: "
	read country
	if [ -z "$country" ]; then
		country=""
	elif [ "$country" = "q" ]; then
		exit 0
	fi
	printf "Optional state info of server location []/q: "
	read state
	if [ -z "$state" ]; then
		state=""
	elif [ "$state" = "q" ]; then
		exit 0
	fi
	printf "Optional city info of server location []/q: "
	read city
	if [ -z "$city" ]; then
		city=""
	elif [ "$city" = "q" ]; then
		exit 0
	fi
	for i in `seq 1 $1`; do
		createport "$i" "$servername" "$country" "$state" "$city"
	done
	printf "\nAll done. Don't forget to put PAK0.PAK and PAK1.PAK in id1/\n"
}

queryports() {
	printf "Max no of ports [4]: "
	read maxports
	if [ -z "$maxports" ]; then
		maxports="4"
	fi
	printf "%s ports, are you sure? (y/n/q): " "$maxports"
	read yn
	if [ -z "$yn" ]; then
		yn="n"
	elif [ "$yn" = "y" ]; then
		createports "$maxports"
	elif [ "$yn" = "n" ]; then
		queryports
	elif [ "$yn" = "q" ]; then
		exit 0
	fi
}

queryports
