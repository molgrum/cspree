/*
    gmapn_vote.qc

    Copyright (C) 2016 Andreas Nilsson

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

void gmapn_vote_reset()
{
	entity player;

	player = find(world, classname, "player");
	while (player)
	{
		gmapn_vote(player, VOTE_NULL);
		player = find(player, classname, "player");
	}

	if (!evoter)
	{
		dprintln("evoter is null!");
		return;
	}

	remove(evoter);
	vote_in_progress = FALSE;
};

void gmapn_vote_cancel()
{
	bprintln(PRINT_HIGH, "The election has exceeded the timelimit!");
	gmapn_vote_reset();
};

float gmapn_vote_check(entity e)
{
	if (vote_in_progress == FALSE)
	{
		sprintln(e, PRINT_HIGH, "No vote in progress.");
		return FALSE;
	}
	if (e.vote != VOTE_NULL)
	{
		sprintln(e, PRINT_HIGH, "You have already voted!");
		return FALSE;
	}

	bprintln(PRINT_HIGH, sprintf(_("%s gives his vote."), e.netname));

	return TRUE;
};

float gmapn_vote_init()
{
	if (vote_in_progress == TRUE)
	{
		sprintln(self, PRINT_HIGH, "A vote is already in progress!");
		return FALSE;
	}

	evoter.nextthink = time + 30;
	evoter.think = gmapn_vote_cancel;
	self.vote = VOTE_YES;
	vote_in_progress = TRUE;

	gmapn_vote_countvotes();

	return TRUE;
};

void gmapn_vote(entity player, float votevalue)
{
	if (player.classname != "player") {
		dprintln("gmapn_vote called with a non-player entity!");
		return;
	}

	if (votevalue < VOTE_NULL || votevalue >= VOTE_TOTAL) {
		dprintln("invalid votevalue!");
		return;
	}

	player.vote = votevalue;

	if (votevalue != VOTE_NULL)
		gmapn_vote_countvotes();
};

void gmapn_vote_countvotes()
{
	entity player;
	float numplayers;
	float numplayersvotedabstain;
	float numplayersvotedyes;
	float numplayersvotedno;
	float numvoters;
	float potentialvotes;
	float target;

	numplayers = 0;
	numplayersvotedabstain = 0;
	numplayersvotedyes = 0;
	numplayersvotedno = 0;
	numvoters = 0;

	player = find(world, classname, "player");
	while(player)
	{
		numplayers++;

		if (player.vote == VOTE_ABSTAIN)
			numplayersvotedabstain++;
		else if (player.vote == VOTE_YES)
			numplayersvotedyes++;
		else if (player.vote == VOTE_NO)
			numplayersvotedno++;
		else if (player.vote != VOTE_NULL)
			dprintln("player vote has an unsupported value!");

		player = find(player, classname, "player");
	}

	if (numplayers <= 0)
	{
		dprintln("voting count with no players!");
		return;
	}

	potentialvotes = numplayers - numplayersvotedabstain;
	target = potentialvotes * 0.5;

	if (numplayersvotedyes > target)
	{
		bprintln(PRINT_HIGH, "Vote passed.");
		evoter.think1();
		gmapn_vote_reset();
	}
	else if (numplayersvotedno >= target)
	{
		bprintln(PRINT_HIGH, "Vote rejected.");
		gmapn_vote_reset();
	}
};
