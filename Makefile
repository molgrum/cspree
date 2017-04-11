VERSION_NUMBER:=`git describe --tags --abbrev=0`
VERSION:=$(shell git rev-parse --git-dir > /dev/null 2>&1 && echo "git" || echo "src")
DATE:=$(shell if $(VERSION)=="git"; then echo "`git log -1 --date="format:%Y %d %b %H:%M" --format=%cd`"; fi)
VERSION:=$(shell git diff-index --quiet HEAD -- && echo "$(VERSION)" || echo "$(VERSION)+dev")
QCC:=./fteqcc

SRC = \
	ss/client.qc \
	ss/gmapn_aliasstuffer.qc \
	ss/gmapn_anticheat.qc \
	ss/gmapn_config.qc \
	ss/gmapn_countdown.qc \
	ss/gmapn_disconnected.qc \
	ss/gmapn_game.qc \
	ss/gmapn_help.qc \
	ss/gmapn_hazards.qc \
	ss/gmapn_http.qc \
	ss/gmapn_init.qc \
	ss/gmapn_keys.qc \
	ss/gmapn_latency.qc \
	ss/gmapn_lightstyle.qc \
	ss/gmapn_mapvote.qc \
	ss/gmapn_menu.qc \
	ss/gmapn_misc.qc \
	ss/gmapn_powerups.qc \
	ss/gmapn_qsg.qc \
	ss/gmapn_reset.qc \
	ss/gmapn_rpickup.qc \
	ss/gmapn_rules.qc \
	ss/gmapn_usercmd.qc \
	ss/gmapn_sql.qc \
	ss/gmapn_stats.qc \
	ss/gmapn_subs.qc \
	ss/gmapn_vote.qc \
	ss/gmapn_votefuncs.qc \
	ss/spectate.qc \
	ss/world.qc \
	ss/defs/builtins.qc \
	ss/defs/constants.qc \
	ss/defs/fields.qc \
	ss/defs/fteextensions.qc \
	ss/defs/functions.qc \
	ss/defs/globals.qc \
	ss/defs/system.qc \
	ss/entities/ammo.qc \
	ss/entities/armor.qc \
	ss/entities/buttons.qc \
	ss/entities/doors.qc \
	ss/entities/health.qc \
	ss/entities/init.qc \
	ss/entities/items.qc \
	ss/entities/keys.qc \
	ss/entities/monsters.qc \
	ss/entities/plats.qc \
	ss/entities/powerups.qc \
	ss/entities/teleports.qc \
	ss/entities/trains.qc \
	ss/entities/triggers.qc \
	ss/entities/weapons.qc \
	ss/frikbot/bot.qc \
	ss/frikbot/bot_ai.qc \
	ss/frikbot/bot_ed.qc \
	ss/frikbot/bot_fight.qc \
	ss/frikbot/bot_misc.qc \
	ss/frikbot/bot_move.qc \
	ss/frikbot/bot_phys.qc \
	ss/frikbot/bot_way.qc \
	ss/models/player.qc \
	ss/monsters/ai.qc \
	ss/monsters/boss.qc \
	ss/monsters/demon.qc \
	ss/monsters/dog.qc \
	ss/monsters/enforcer.qc \
	ss/monsters/fight.qc \
	ss/monsters/fish.qc \
	ss/monsters/hknight.qc \
	ss/monsters/knight.qc \
	ss/monsters/monsters.qc \
	ss/monsters/ogre.qc \
	ss/monsters/oldone.qc \
	ss/monsters/shalrath.qc \
	ss/monsters/shambler.qc \
	ss/monsters/soldier.qc \
	ss/monsters/tarbaby.qc \
	ss/monsters/wizard.qc \
	ss/monsters/zombie.qc

../cspree/qwprogs.dat: $(SRC)
	{ echo "#define VERSION \"$(VERSION_NUMBER) $(VERSION)\""; echo "#define DATE \"$(DATE)\""; } > version.qc
	$(QCC)

ctags: $(SRC)
	ctags $^

etags: $(SRC)
	etags $^

clean:
	rm -f qwprogs.dat qwprogs.lno

all: ../cspree/qwprogs.dat
