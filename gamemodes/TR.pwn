/*
>> Gamemode namijenjen da bi nekome pomogao !
>> Subscribe na kanal : kaizer :P

TODO:
Napraviti register login sistem

FIXME:
Popraviti bugove
*/

//********************* SAMP INCLUDE*********************//
#include <		a_samp				>
#include < 		a_mysql				>
//********************* OFFICIAL INCLUDE *********************//
#include <		streamer 			>
#include < 		YSI_Data\y_iterate 	>
#include < 		YSI_Coding\y_va 	> 
#include < 		sscanf2				>
#include < 		Pawn.CMD 			>
#include < 		GPS	 				>
//********************* MY INCLUDES *********************//
#include "modules\globaltds.pwn"
#include "modules\playertds.pwn"
#include "modules\maps.pwn"
#include "modules\variables.pwn"
//******************************************************//
#define IME_SERVERA 	"Treasure RolePlay"
#define VERZIJA_SKRIPTE	"T:RP - x0.1"
#define DEVELOPER		"kaizer"
#define FORUM 			"www.balkanhub.info"

#define MYSQL_HOST		"localhost"
#define MYSQL_USER 		"root"
#define MYSQL_PASS		""
#define MYSQL_DB 		"treasure-rp"
 
//************************ BOJE *************************//
#define bijela_boja     0xFFFFFFAA
#define proxy_boja      0xC2A2DAAA 
#define BIJELA 			"{FFFFFF}"
#define CRVENA 			"{FF0000}"
//******************************************************//
#define DIALOG_LOGIN        	0
#define DIALOG_REGISTRACIJA 	1
//******************************************************//
new MySQL:SQL;
new IC_CHAT = 1;
new bool:IgracUlogovan[MAX_PLAYERS];
//******************************************************//
enum IgraceveInformacije {
	SQLID,
	Username[MAX_PLAYER_NAME],
	Password,
	Level,
	Novac,
	Skin,
	Admin
}
new IgracInfo[MAX_PLAYERS][IgraceveInformacije];
//******************************************************//
main(){
	print("\n----------------------------------");
	printf(" >> IME SERVERA : %s",IME_SERVERA);
	printf(" >> VERZIJA SKRIPTE : %s",VERZIJA_SKRIPTE);
	printf(" >> DEVELOPER : %s",DEVELOPER);
	printf(" >> FORUM : %s",FORUM);
	print("----------------------------------\n");
}
//******************************************************//
public OnGameModeInit(){
	//****************************************************************************//
	SQL = mysql_connect(MYSQL_HOST,MYSQL_USER,MYSQL_PASS,MYSQL_DB);
	if(SQL == MYSQL_INVALID_HANDLE || mysql_errno(SQL) != 0)
	{
		print("MySQL >> Niste se uspjeli konektovati na data bazu, gasim server.");
		SendRconCommand("exit");
		return 1;
	}
	print("MySQL >> Uspjesno smo se konektovali na SQL server.");
	//****************************************************************************//
	new verzijamoda[18];
	format(verzijamoda, sizeof(verzijamoda),"%s", VERZIJA_SKRIPTE);
	SetGameModeText(verzijamoda);
	new forumlink[28];
	format(forumlink, sizeof(forumlink),"weburl %s", FORUM);
	SendRconCommand(forumlink);
	EnableStuntBonusForAll(0); DisableInteriorEnterExits();
	AllowInteriorWeapons(1); ShowPlayerMarkers(false);
	KreirajGlobalneTD(); KreirajMape();
	//****************************************************************************//
	AddPlayerClass(60, 816.4385,-1354.6329,-0.5078,230.8921, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit(){
	mysql_close(SQL);
	return 1;
}

public OnPlayerRequestClass(playerid, classid){
	if(IgracUlogovan[playerid] == true)
	{
		SpawnPlayer(playerid);
	}
	return 1;
}

public OnPlayerConnect(playerid) {
	OcistiChat(playerid, 16); ResetujVarijable(playerid);
	IgracUlogovan[playerid] = false;
	new query[100];
	mysql_format(SQL, query,sizeof query,"SELECT * FROM bans WHERE IGRAC='%e'",GetName(playerid));
	mysql_tquery(SQL,query,"ProvjeriBAN","d",playerid);
	return 1;
} 
forward ProvjeriBAN(playerid);
public ProvjeriBAN(playerid) {
	static rows;
	cache_get_row_count(rows);
	if(!rows) {
		new query[100],IP[50];
		GetPlayerIp(playerid, IP, sizeof IP);
		mysql_format(SQL, query,sizeof query,"SELECT * FROM bans WHERE IP='%e'",IP);
		mysql_tquery(SQL,query,"ProvjeriBANIP","ds",playerid,IP);
	} else {
		va_SendClientMessage(playerid, -1, ""CRVENA"TREASURE RP: "BIJELA"Vas racun "CRVENA"'%s'"BIJELA" je banovan sa servera, ne mozete pristupiti serveru !", GetName(playerid));
		SetTimerEx("BAN_TIMER", 1000, false, "d", playerid);
	}
}
forward ProvjeriBANIP(playerid,IP);
public ProvjeriBANIP(playerid,IP) {
	static rows;
	cache_get_row_count(rows);
	if(!rows) {
		//********************************//
		KreirajPlayerTD(playerid); ResetPlayerMoney(playerid);
		for(new i = 0; i < 13; i++) { TextDrawShowForPlayer(playerid, LOGREG_TD[i]); }
		new Igracev_Nick[MAX_PLAYER_NAME];
		format(Igracev_Nick, sizeof(Igracev_Nick),"%s",GetName(playerid));
		PlayerTextDrawSetString(playerid, USERNAME_TD[playerid][0], Igracev_Nick);
		PlayerTextDrawShow(playerid, USERNAME_TD[playerid][0]);
		SelectTextDraw(playerid, 0xFFFFFFAA);
		//********************************//
	} else {
		va_SendClientMessage(playerid, -1, ""CRVENA"TREASURE RP: "BIJELA"Vas IP "CRVENA"'%s'"BIJELA" je banovan sa servera, ne mozete pristupiti serveru !", IP);
		SetTimerEx("BAN_TIMER", 1000, false, "d", playerid);
	}
}
public OnPlayerDisconnect(playerid, reason){
	IgracUlogovan[playerid] = false; IgracInfo[playerid][SQLID] = -1;
	return 1;
}
public OnPlayerSpawn(playerid){
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason){
	return 1;
}

public OnVehicleSpawn(vehicleid){
	return 1;
}

public OnVehicleDeath(vehicleid, killerid){
	return 1;
}
public OnPlayerText(playerid, text[]){
	if(IC_CHAT){
	    new string[256];
	    format(string,sizeof(string), "%s kaze: %s",GetName(playerid), text);
	    ProxDetector(20.0, playerid, string, bijela_boja,bijela_boja,bijela_boja,bijela_boja,bijela_boja);
	    return false;
	}
	return 1;
}

cmd:me(playerid, params[]){
	new text[80];
	if(sscanf(params, "s[80]", text)) return SendClientMessage(playerid, -1,"{FF0000}USAGE: {FFFFFF}/me [Text]");
	new string[256];
 	format(string,sizeof(string), "* %s %s",GetName(playerid), text);
 	ProxDetector(20.0, playerid, string, proxy_boja,proxy_boja,proxy_boja,proxy_boja,proxy_boja);
	return 1;
}
cmd:do(playerid, params[]){
	new text[80];
	if(sscanf(params, "s[80]", text)) return SendClientMessage(playerid, -1,"{FF0000}USAGE: {FFFFFF}/do [Text]");
	new string[256];
 	format(string,sizeof(string), "* %s (( %s ))",GetName(playerid), text);
 	ProxDetector(20.0, playerid, string, proxy_boja,proxy_boja,proxy_boja,proxy_boja,proxy_boja);
	return 1;
}
cmd:b(playerid, params[]){
	new text[80];
	if(sscanf(params, "s[80]", text)) return SendClientMessage(playerid, -1,"{FF0000}USAGE: {FFFFFF}/b [Text]");
	new string[256];
 	format(string,sizeof(string), "{C0C0C0}(( [OOC] {FFFFFF}%s kaze : %s {C0C0C0}))",GetName(playerid), text);
 	ProxDetector(20.0, playerid, string, proxy_boja,proxy_boja,proxy_boja,proxy_boja,proxy_boja);
	return 1;
}
cmd:aduty(playerid) {
	if(IgracUlogovan[playerid] == false) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ulogovani !");
	if(IgracInfo[playerid][Admin] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ovlasteni !");
	if(AdminDuty[playerid] == 0) {
		AdminDuty[playerid] = 1;
		SetPlayerHealth(playerid, 99999);
		SetPlayerArmour(playerid, 99.9);
		SetPlayerSkin(playerid, 294);
		va_SendClientMessageToAll(-1,""CRVENA"A-DUTY: "BIJELA"Admin %s je na duznosti, "CRVENA"/report "BIJELA"da prijavite nesto !",GetName(playerid));
	} else if(AdminDuty[playerid] == 1) {
		SetPlayerSkin(playerid, IgracInfo[playerid][Skin]);
		AdminDuty[playerid] = 0;
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 0);
		va_SendClientMessageToAll(-1,""CRVENA"A-DUTY: "BIJELA"Admin %s vise nije na duznosti "CRVENA"!",GetName(playerid));
	}
	return true;
}
alias:aduty("aon","adminduty")

cmd:kick(playerid,params[]) {
	if(IgracUlogovan[playerid] == false) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ulogovani !");
	if(IgracInfo[playerid][Admin] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ovlasteni !");
	if(AdminDuty[playerid] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste na duznosti "CRVENA"(/aduty)"BIJELA" !");
	new ID,RAZLOG[12];
	if(sscanf(params,"ds[12]",ID,RAZLOG)) return SendClientMessage(playerid, -1,""CRVENA"KORISTI: "BIJELA"/KICK [ID] [RAZLOG]");
	printf("[LOG]: Admin %s je kikovao %s, razlog: %s",GetName(playerid),GetName(ID),RAZLOG);
	va_SendClientMessageToAll(-1,""CRVENA"TREASURE-RP: "BIJELA"%s je kikovao %s, razlog: "CRVENA"%s",GetName(playerid),GetName(ID),RAZLOG);
	va_SendClientMessage(playerid, -1,""CRVENA"KICK: "BIJELA"Izbacili ste %s sa servera zbog :"CRVENA" %s",GetName(ID),RAZLOG);
	Kick(ID);
	return true;
}
cmd:ban(playerid,params[]) {
	if(IgracUlogovan[playerid] == false) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ulogovani !");
	if(IgracInfo[playerid][Admin] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ovlasteni !");
	if(AdminDuty[playerid] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste na duznosti "CRVENA"(/aduty)"BIJELA" !");
	new ID,RAZLOG[12];
	if(sscanf(params,"ds[12]",ID,RAZLOG)) return SendClientMessage(playerid, -1,""CRVENA"KORISTI: "BIJELA"/BAN [ID] [RAZLOG]");
	printf("[LOG]: Admin %s je banovao %s, razlog: %s",GetName(playerid),GetName(ID),RAZLOG);
	va_SendClientMessageToAll(-1,""CRVENA"TREASURE-RP: "BIJELA"%s je banovao %s, razlog: "CRVENA"%s",GetName(playerid),GetName(ID),RAZLOG);
	va_SendClientMessage(playerid, -1,""CRVENA"BAN: "BIJELA"Banovali ste %s sa servera zbog :"CRVENA" %s",GetName(ID),RAZLOG);
	new godina,mjesec,dan,sat,minuta, datumvar[32], query[260];
	gettime(sat,minuta); getdate(godina,mjesec,dan);
	format(datumvar, sizeof datumvar, "%d/%d/%d - %d:%d", dan,mjesec,godina,sat,minuta);
	mysql_format(SQL, query,sizeof query,"INSERT INTO `bans` (`ID`,`ADMIN`,`IGRAC`,`RAZLOG`,`DATUM`,`IP`) \
		VALUES('%d','%e','%e','%e','%e','-1')", IgracInfo[ID][SQLID], GetName(playerid), GetName(ID), RAZLOG, datumvar);
	mysql_tquery(SQL, query);
	SetTimerEx("BAN_TIMER", 1000, false, "d", ID);
	return true;
}
cmd:banip(playerid,params[]) {
	if(IgracUlogovan[playerid] == false) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ulogovani !");
	if(IgracInfo[playerid][Admin] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ovlasteni !");
	if(AdminDuty[playerid] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste na duznosti "CRVENA"(/aduty)"BIJELA" !");
	new ID,RAZLOG[12];
	if(sscanf(params,"ds[12]",ID,RAZLOG)) return SendClientMessage(playerid, -1,""CRVENA"KORISTI: "BIJELA"/BANIP [ID] [RAZLOG]");
	printf("[LOG]: Admin %s je banovao IP %s, razlog: %s",GetName(playerid),GetName(ID),RAZLOG);
	va_SendClientMessageToAll(-1,""CRVENA"TREASURE-RP: "BIJELA"%s je banovao %s, razlog: "CRVENA"%s",GetName(playerid),GetName(ID),RAZLOG);
	va_SendClientMessage(playerid, -1,""CRVENA"BAN|IP: "BIJELA"Banovali ste %s sa servera zbog :"CRVENA" %s",GetName(ID),RAZLOG);
	new godina,mjesec,dan,sat,minuta, datumvar[32], query[260],Igracev_IP[50];
	GetPlayerIp(playerid, Igracev_IP, sizeof Igracev_IP);
	gettime(sat,minuta); getdate(godina,mjesec,dan);
	format(datumvar, sizeof datumvar, "%d/%d/%d - %d:%d", dan,mjesec,godina,sat,minuta);
	mysql_format(SQL, query,sizeof query,"INSERT INTO `bans` (`ID`,`ADMIN`,`IGRAC`,`RAZLOG`,`DATUM`,`IP`) \
		VALUES('%d','%e','%e','%e','%e','%e')", IgracInfo[ID][SQLID], GetName(playerid), GetName(ID), RAZLOG, datumvar,Igracev_IP);
	mysql_tquery(SQL, query);
	SetTimerEx("BAN_TIMER", 1000, false, "d", ID);
	return true;
}
cmd:unban(playerid,params[]) {
	if(IgracUlogovan[playerid] == false) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ulogovani !");
	if(IgracInfo[playerid][Admin] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste ovlasteni !");
	if(AdminDuty[playerid] == 0) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Niste na duznosti "CRVENA"(/aduty)"BIJELA" !");
	new IME_IGRACA[MAX_PLAYER_NAME];
	if(sscanf(params,"s[25]",IME_IGRACA)) return SendClientMessage(playerid, -1,""CRVENA"KORISTI: "BIJELA"/UNBAN [IME_IGRACA]"); 
	new query[100]; 
	mysql_format(SQL, query,sizeof query,"SELECT * FROM bans WHERE IGRAC='%e'", IME_IGRACA);
	mysql_tquery(SQL, query,"ProvjeriUNBAN","is",playerid, IME_IGRACA); 
	return true;
}
forward ProvjeriUNBAN(playerid,IME_IGRACA);
public ProvjeriUNBAN(playerid,IME_IGRACA) {
	static rows;
	cache_get_row_count(rows);
	if(!rows) { va_SendClientMessage(playerid, -1, ""CRVENA"TREASURE RP: "BIJELA"Account "CRVENA"'%s'"BIJELA" nije pronadjen u databazi banova !", IME_IGRACA); }
	else {
		va_SendClientMessageToAll(-1,""CRVENA"TREASURE-RP: "BIJELA"%s je unbanovao %s.",GetName(playerid),IME_IGRACA);
		va_SendClientMessage(playerid, -1,""CRVENA"UNBAN: "BIJELA"Unbanovali ste %s sa servera !",IME_IGRACA);
		printf("[LOG]: Admin %s je unbanovao %s",GetName(playerid),IME_IGRACA);
		new query[100]; 
		mysql_format(SQL, query,sizeof query,"DELETE FROM bans WHERE IGRAC='%e'", IME_IGRACA);
		mysql_tquery(SQL, query); 
	}
}
forward BAN_TIMER(playerid);
public BAN_TIMER(playerid) {
	Ban(playerid);
	return true;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger){
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid){
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate){
	return 1;
}

public OnPlayerEnterCheckpoint(playerid){
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid){
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid){
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid){
	return 1;
}

public OnRconCommand(cmd[]){
	return 1;
}
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == LOGREG_TD[5]) {
		new query[150];
		mysql_format(SQL,query,sizeof(query),"SELECT * FROM `players` WHERE `Username` = '%e'",GetName(playerid));
		mysql_tquery(SQL,query,"SQL_ProvjeraAccounta", "i", playerid);
	}
	if(clickedid == LOGREG_TD[6]) {
		new query[150];
		mysql_format(SQL,query,sizeof(query),"SELECT * FROM `players` WHERE `Username` = '%e'",GetName(playerid));
		mysql_tquery(SQL,query,"SQL_ProvjeraAccounta", "i", playerid);
	}
    return 1;
}
public OnPlayerRequestSpawn(playerid){
	return 1;
}

public OnObjectMoved(objectid){
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid){
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid){
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid){
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid){
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2){
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row){
	return 1;
}

public OnPlayerExitedMenu(playerid){
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid){
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success){
	return 1;
}

public OnPlayerUpdate(playerid){
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid){
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid){
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid){
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid){
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	if(dialogid == DIALOG_REGISTRACIJA) {
		if(!response) return Kick(playerid);
		if(strlen(inputtext) <= 5 || strlen(inputtext) > 60)
		{
			SendClientMessage(playerid, -1,""CRVENA"GRESKA : "BIJELA"Vas password mora imati najmanje 6 karaktera i ne smije biti preko 60 karaktera !");
			new string[256];
		    format(string,sizeof(string),"Korisnicki racun %s nije pronadjen, upisite lozinku koju zelite koristiti", GetName(playerid));
		    ShowPlayerDialog(playerid,DIALOG_REGISTRACIJA, DIALOG_STYLE_PASSWORD, "TREASURE RP", string, "Registruj se", "Izlaz");
		}
		else {
			CancelSelectTextDraw(playerid);
			IgracInfo[playerid][Password] = udb_hash(inputtext);
			SendClientMessage(playerid, -1,""CRVENA"TREASURE: "BIJELA" Uspjesno ste se registrovali na nas server, uzivajte igrajuci !");
			//**************************************************************************************************************//
			new query[500];
			mysql_format(SQL, query,sizeof(query),"INSERT INTO `players` (`Username`,`Password`,`Skin`,`Level`,`Novac`) \
				VALUES ('%e','%d','60','1','2000')",
				GetName(playerid),
				IgracInfo[playerid][Password]);
			mysql_tquery(SQL,query,"IgracRegistrovan", "i",playerid);
			//**************************************************************************************************************//
		}
	}
	if(dialogid == DIALOG_LOGIN) {
		if(!response) return Kick(playerid);
		if(response) {
			if(udb_hash(inputtext) == IgracInfo[playerid][Password]) {
				if(IgracUlogovan[playerid] == true) return SendClientMessage(playerid, -1,""CRVENA"ERROR: "BIJELA"Vi ste vec ulogovani !");
				CancelSelectTextDraw(playerid);
				TogglePlayerSpectating(playerid, false);
				SetPlayerScore(playerid, 	IgracInfo[playerid][Level]);
				GivePlayerMoney(playerid, IgracInfo[playerid][Novac]);
				IgracUlogovan[playerid] = true;
				OcistiChat(playerid, 16);
				//*****************************************************************//
				va_SendClientMessage(playerid, -1,"Dobrodosli "CRVENA"%s "BIJELA"ponovo na nas server, za pomoc koristite "CRVENA"/askq "BIJELA"ili "CRVENA"/report", GetName(playerid));
				va_SendClientMessage(playerid, -1,"Vas level na serveru je "CRVENA"%d"BIJELA", uzivajte igrajuci", IgracInfo[playerid][Level]);
				//*****************************************************************//
				SpawnPlayer(playerid);
				SetCameraBehindPlayer(playerid);
			}
			else {
				SendClientMessage(playerid, -1,""CRVENA"GRESKA : "BIJELA"Vas password nije tacan !");
				new string[256];
			    format(string,sizeof(string),"Korisnicki racun %s je pronadjen, upisite lozinku koju ste koristili", GetName(playerid));
			    ShowPlayerDialog(playerid,DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "TREASURE RP", string, "Uloguj se", "Izlaz");
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source){
	return 1;
}
//***************************************************************//
GetName(playerid){
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}
ResetujVarijable(playerid) {
 	IgracInfo[playerid][SQLID] = -1; IgracInfo[playerid][Novac] = 0; IgracInfo[playerid][Skin] = 60;
 	IgracInfo[playerid][Level] = 1;
	return true;
}
udb_hash(const buf[]) {
    new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}
SacuvajNalog(playerid) {
	if(IgracUlogovan[playerid] == true) { 
		new query[500];
		mysql_format(SQL,query,sizeof(query),"UPDATE `players` SET `Level` = '%d',`Novac` = '%d',`Skin` = '%d',`Admin` = '%d' WHERE `ID` = '%d'",
			IgracInfo[playerid][Level],
			IgracInfo[playerid][Novac],
			IgracInfo[playerid][Skin],
			IgracInfo[playerid][Admin],
			IgracInfo[playerid][SQLID]);
		mysql_tquery(SQL,query); 
	}
	return true;
} 
forward IgracRegistrovan(playerid);
public IgracRegistrovan(playerid) {
	if(IgracUlogovan[playerid] == true) return SendClientMessage(playerid, -1,""CRVENA"GRESKA : "BIJELA"Vi ste vec ulogovani !");
	IgracInfo[playerid][Skin] = 60; IgracInfo[playerid][SQLID]  =  cache_insert_id();
	IgracInfo[playerid][Level] = 1;
	IgracInfo[playerid][Novac] = 2000;
	TogglePlayerSpectating(playerid, false);
	OcistiChat(playerid, 16);
	va_SendClientMessage(playerid, -1,""CRVENA"%s"BIJELA" vi ste uspjesno registrovani na "CRVENA"Trea"BIJELA"sure "CRVENA"Role"BIJELA"play samp server !",GetName(playerid));
	va_SendClientMessage(playerid, -1,"Vas nivo je "CRVENA"%d"BIJELA", uzivajte igrajuci na serveru !",IgracInfo[playerid][Level]);
	IgracUlogovan[playerid] = true;
	SetPlayerScore(playerid, IgracInfo[playerid][Level]);
	GivePlayerMoney(playerid, IgracInfo[playerid][Novac]);
	SacuvajNalog(playerid);
	SetSpawnInfo( playerid, 0, IgracInfo[playerid][Skin], 1484.8005,-1615.9725,14.1292,359.3905, 0, 0, 0, 0, 0, 0 );
	SpawnPlayer(playerid);
	return true;
}
forward SQL_ProvjeraAccounta(playerid);
public SQL_ProvjeraAccounta(playerid) {
	static rows;
	cache_get_row_count(rows);
	if(!rows) {
		for(new i = 0; i < 13; i++){
			TextDrawHideForPlayer(playerid, LOGREG_TD[i]);
		}
		PlayerTextDrawHide(playerid, USERNAME_TD[playerid][0]);
	    new string[256];
	    format(string,sizeof(string),"Korisnicki racun %s nije pronadjen, upisite lozinku koju zelite koristiti", GetName(playerid));
	    ShowPlayerDialog(playerid,DIALOG_REGISTRACIJA, DIALOG_STYLE_PASSWORD, "TREASURE RP", string, "Registruj se", "Izlaz");
	}
	else {
		for(new i = 0; i < 13; i++){
			TextDrawHideForPlayer(playerid, LOGREG_TD[i]);
		}
		PlayerTextDrawHide(playerid, USERNAME_TD[playerid][0]);
	    cache_get_value_name_int(0, "ID", IgracInfo[playerid][SQLID]);
	    cache_get_value_name_int(0, "Password", IgracInfo[playerid][Password]);
	    cache_get_value_name_int(0, "Skin", IgracInfo[playerid][Skin]);
	    cache_get_value_name_int(0, "Novac", IgracInfo[playerid][Novac]);
	    cache_get_value_name_int(0, "Level", IgracInfo[playerid][Level]);
	    cache_get_value_name_int(0, "Admin", IgracInfo[playerid][Admin]);
	    new string[256];
	    format(string,sizeof(string),"Korisnicki racun %s je pronadjen, upisite lozinku koju ste koristili", GetName(playerid));
	    ShowPlayerDialog(playerid,DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "TREASURE RP", string, "Uloguj se", "Izlaz");
	}
}
forward OcistiChat(playerid, brojlinija);
public OcistiChat(playerid, brojlinija){
	for(new i=0; i<brojlinija; i++){
		SendClientMessage(playerid,-1," ");
	}
}
forward ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5);
public ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5){
    if(IsPlayerConnected(playerid)){
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        foreach(new i : Player){
            if(IsPlayerConnected(i)){
                if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)){
                    GetPlayerPos(i, posx, posy, posz);
                    tempposx = (oldposx -posx);
                    tempposy = (oldposy -posy);
                    tempposz = (oldposz -posz);
                    if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))){
                        SendClientMessage(i, col1, string);
                    }
                    else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8))){
                        SendClientMessage(i, col2, string);
                    }
                    else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4))){
                        SendClientMessage(i, col3, string);
                    }
                    else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2))){
                        SendClientMessage(i, col4, string);
                    }
                    else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))){
                        SendClientMessage(i, col5, string);
                    }
            }   }
        }
    }
    return 1;
}
