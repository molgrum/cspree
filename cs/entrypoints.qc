/**
	CSQC_UpdateView, in a nutshell, runs each frame and renders pretty much everything you see.
*/

void(float width, float height, float menushown) CSQC_UpdateView =
{
	clearscene(); //wipe the scene, and apply the default rendering values.

	setviewprop(VF_MIN_X, 0);   //set the left of the view
	setviewprop(VF_MIN_Y, 0);   //set the top of the view
	setviewprop(VF_SIZE_X, width);   //set how wide the view is (full width)
	setviewprop(VF_SIZE_Y, height); //set how high the view is (full height)
	
	setviewprop(VF_DRAWENGINESBAR, TRUE);	//enable the engine's normal sbar (or ezhud or whatever).
	setviewprop(VF_DRAWCROSSHAIR, TRUE);	//crosshair should be visible too.

	addentities(MASK_ENGINE|MASK_VIEWMODEL);
	renderscene();

	if (!menushown)
	{
		void(float w, float y, string s) drawcenterstring =
		{
			float x = (w-stringwidth(s, TRUE, '8 8'))/2;
			drawstring([x,y], s, '8 8', '1 1 1', 1, 0);
		};
		drawcenterstring(width, 8*4, "CSPREE "VERSION);
		drawcenterstring(width, 8*5, sprintf("Game mode %g, round %g of %g", getstatf(STAT_GAMEMODE), getstatf(STAT_CURROUND), getstatf(STAT_MAXROUND)));
		drawcenterstring(width, 8*6, sprintf("Red: %g : %g :Blue", getstatf(STAT_TEAMSCORES_RED), getstatf(STAT_TEAMSCORES_BLUE)));
		if (getstatf(STAT_READY))
			drawcenterstring(width, 8*7, "You are Ready");
		else
			drawcenterstring(width, 8*7, "You are \bNOT\b Ready");
	}
};

