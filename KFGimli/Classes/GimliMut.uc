// -------------------------------------------------------------
// Killing Floor Mutator
// Repair "Gimli That Axe!" Steam Achievement on Server-side
// Created by Heatray, https://s.team/p/kff-tvmg
// -------------------------------------------------------------

class GimliMut extends Mutator;

var KFPlayerController Player;
var KFSteamStatsAndAchievements SteamStatsAndAchievements;
var KFSteamWebApiFix SteamWebApi;
var string userName;
var string steamID;

function ModifyPlayer(Pawn Other)
{
	Super.ModifyPlayer(Other);

	Player = KFPlayerController(Other.Controller);
	SteamStatsAndAchievements = KFSteamStatsAndAchievements(Other.PlayerReplicationInfo.SteamStatsAndAchievements);

	if (Player != None && SteamStatsAndAchievements != None)
	{
		userName = Player.PlayerOwnerName;
		steamID = SteamStatsAndAchievements.GetSteamUserID();

		if (SteamStatsAndAchievements.Achievements[208].bCompleted != 1)
		{
			Log("GIMLI FIX: Checking for" @ userName @ "id=" $ steamID);
			SetupWebAPI();
		}
	}
}

function SetupWebAPI()
{
	if (SteamWebApi == None)
		SteamWebApi = Spawn(class'KFSteamWebApiFix', self);

	SteamWebApi.AchievementReport = SteamStatsAndAchievements.OnAchievementReport;
	SteamWebApi.steamName = userName;
	SteamWebApi.GetAchievements(steamID);
}

DefaultProperties
{
	GroupName="KF-GimliMut"
	FriendlyName="Achievement Fix [S]: Gimli That Axe!"
	Description="Repair Gimli That Axe! achievement on server-side|Get the Not-a-war-hammer Achievement in Dwarfs!? F2P|Created by Heatray, 25.08.2020"
}
