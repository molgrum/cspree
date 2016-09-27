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

	renderscene();
};

