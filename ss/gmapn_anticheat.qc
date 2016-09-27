/*
    gmapn_anticheat.qc

    Copyright (C) 2009 Andreas Nilsson

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to:

        Free Software Foundation, Inc.
        59 Temple Place - Suite 330
        Boston, MA  02111-1307, USA

*/

void gmapn_detect_fast_angles()
{
	float f;

	f = self.angles_y - self.angles_previous;
	f = fabs(f);
	if (f > 180)
		f = 360 - f;

	self.angles_previous = self.angles_y;

	// TODO: Make this work
	if (f > 170)
	{
/*
			bprint(PRINT_HIGH, "Rocketjump script detected on ");
			bprint(PRINT_HIGH, self.netname);
			bprint(PRINT_HIGH, "! Angles per frame was ");
			bprint(PRINT_HIGH, ftos(f));
			bprint(PRINT_HIGH, "\n");
*/
	}
};
