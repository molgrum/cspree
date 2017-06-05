void URI_Get_Callback(float reqid, float responsecode, string resourcebody)
{
	if (responsecode != 0)
	{
		// 200 OK is sent here as 0
		dprint("HTTP responsecode ", ftos(responsecode), " for request id: ", ftos(reqid), "\n");
	}

	if (reqid == URI_GET_MAPLIST)
	{
		int nummaps = 0;
		float argc;

		if (responsecode != 0)
		{
			gmapn_menu_mapvote_sql();
			return;
		}

		argc = tokenize(resourcebody);
		for (int i = 0; i < argc && nummaps < maps.length-4; i++)
		{
			int mapidx;
			string map = argv(i);

			if (map == "")
				continue;

			mapidx = gmapn_map_pool_findidx(map);
			if (mapidx >= 0)
				self.maps[nummaps++] = mapidx;
		}

		if (!nummaps)
			gmapn_menu_mapvote_sql();
		else
			menu_mapvote_randomize(nummaps);
	}
}
