void gmapn_newrulemaker()
{
	gmapn_gamemaster = evoter.owner;
	bprintln(PRINT_HIGH, sprintf(_("%s becomes a rulemaker"), gmapn_gamemaster.netname));

	remove(evoter);
};

void gmapn_kick()
{
	entity target = evoter.enemy;

	localcmd("kick ");
	localcmd(infokey(target, INFOKEY_P_USERID));
	localcmd("\n");

	remove(evoter);
};

void gmapn_ban()
{
	entity target = evoter.enemy;

	localcmd("addip ");
	localcmd(infokey(target, INFOKEY_P_REALIP));
	localcmd(" ban\n");

	localcmd("kick ");
	localcmd(infokey(target, INFOKEY_P_USERID));
	localcmd("\n");
};

void gmapn_mute()
{
	entity target = evoter.enemy;

	localcmd("addip ");
	localcmd(infokey(target, INFOKEY_P_REALIP));
	localcmd(" mute\n");
};
