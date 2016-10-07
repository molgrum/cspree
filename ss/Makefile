QCC = ../fteqcc

INSTALL_DIR = ~/quake/gmapn

SRC = \
	client.qc \
	gmapn_aliasstuffer.qc \
	gmapn_anticheat.qc \
	gmapn_config.qc \
	gmapn_countdown.qc \
	gmapn_disconnected.qc \
	gmapn_game.qc \
	gmapn_help.qc \
	gmapn_hazards.qc \
	gmapn_init.qc \
	gmapn_keys.qc \
	gmapn_latency.qc \
	gmapn_lightstyle.qc \
	gmapn_mapvote.qc \
	gmapn_menu.qc \
	gmapn_misc.qc \
	gmapn_powerups.qc \
	gmapn_qsg.qc \
	gmapn_reset.qc \
	gmapn_rpickup.qc \
	gmapn_rules.qc \
	gmapn_usercmd.qc \
	gmapn_subs.qc \
	gmapn_vote.qc \
	gmapn_votefuncs.qc \
	spectate.qc \
	world.qc \
	defs/builtins.qc \
	defs/constants.qc \
	defs/fields.qc \
	defs/functions.qc \
	defs/globals.qc \
	defs/system.qc \
	entities/ammo.qc \
	entities/armor.qc \
	entities/buttons.qc \
	entities/doors.qc \
	entities/health.qc \
	entities/init.qc \
	entities/items.qc \
	entities/keys.qc \
	entities/monsters.qc \
	entities/plats.qc \
	entities/powerups.qc \
	entities/teleports.qc \
	entities/trains.qc \
	entities/triggers.qc \
	entities/weapons.qc \
	frikbot/bot.qc \
	frikbot/bot_ai.qc \
	frikbot/bot_ed.qc \
	frikbot/bot_fight.qc \
	frikbot/bot_misc.qc \
	frikbot/bot_move.qc \
	frikbot/bot_phys.qc \
	frikbot/bot_way.qc \
	models/player.qc

../../gmapn/qwprogs.dat: $(SRC)
	$(QCC)

install: ../../gmapn/qwprogs.dat
	mkdir -p $(INSTALL_DIR)
	cp ../../gmapn/qwprogs.dat $(INSTALL_DIR)

ctags: $(SRC)
	ctags $^

etags: $(SRC)
	etags $^

clean:
	rm -f ../../gmapn/qwprogs.dat ../../gmapn/qwprogs.lno

