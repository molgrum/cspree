void URI_Get_Callback(float reqid, float responsecode, string resourcebody)
{
	if (responsecode != 0)
	{
		// 200 OK is sent here as 0
		dprint("HTTP responsecode ", ftos(responsecode), " for request id: ", ftos(reqid), "\n");
	}

	if (reqid == URI_GET_MAPLIST)
	{
		float argc;
		float populated = FALSE;

		if (responsecode != 0)
		{
			gmapn_menu_mapvote_sql();
			return;
		}

		argc = min(tokenize(resourcebody), MAPLIMIT);

		for (int i = 0; i < argc; i++)
		{
			int mapidx;
			string map = argv(i);

			if (map == "")
				continue;

			for (mapidx = 0; infokey(world, strcat("gmapn_map", ftos(mapidx))) != ""; mapidx++)
			{
				if (infokey(world, strcat("gmapn_map", ftos(mapidx))) == map)
				{
					self.maps[i] = mapidx;
					populated = TRUE;
					break;
				}
			}
		}

		if (populated == FALSE)
			gmapn_menu_mapvote_sql();
	}
}
