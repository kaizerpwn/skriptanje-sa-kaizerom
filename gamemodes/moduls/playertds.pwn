new PlayerText:USERNAME_TD[MAX_PLAYERS][1];

KreirajPlayerTD(playerid) {
	USERNAME_TD[playerid][0] = CreatePlayerTextDraw(playerid, 314.666625, 185.436981, "Johny_Wiliams");
	PlayerTextDrawLetterSize(playerid, USERNAME_TD[playerid][0], 0.136000, 0.786962);
	PlayerTextDrawAlignment(playerid, USERNAME_TD[playerid][0], 1);
	PlayerTextDrawColor(playerid, USERNAME_TD[playerid][0], -1523963137);
	PlayerTextDrawSetShadow(playerid, USERNAME_TD[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, USERNAME_TD[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, USERNAME_TD[playerid][0], 255);
	PlayerTextDrawFont(playerid, USERNAME_TD[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, USERNAME_TD[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, USERNAME_TD[playerid][0], 0);
}