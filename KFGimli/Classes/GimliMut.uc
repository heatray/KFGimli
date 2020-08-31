//--------------------------------------------------------------
// Killing Floor Mutator
// Repair "Gimli That Axe!" Steam Achievement on server-side
// Created by Heatray, https://s.team/p/kff-tvmg
//--------------------------------------------------------------

class GimliMut extends Mutator;

var array<string> aChecks;

function PostBeginPlay()
{
	Log("GIMLI FIX: Init");
}

function ModifyPlayer(Pawn Other)
{
	local KFPlayerController Player;
	local KFSteamStatsAndAchievements SteamStats;
	local KFSteamWebApiNew SteamWebApi;
	local string userName;
	local string steamID;
	local int i;
	local bool bChecked;

	Super.ModifyPlayer(Other);

	Player = KFPlayerController(Other.Controller);
	SteamStats = KFSteamStatsAndAchievements(Other.PlayerReplicationInfo.SteamStatsAndAchievements);

	if (Player != None && SteamStats != None)
	{
		userName = Player.PlayerOwnerName;
		steamID = SteamStats.GetSteamUserID();

		for (i = 0; i < aChecks.Length; ++i)
			if (aChecks[i] == steamID)
				bChecked = true;

		if (SteamStats.Achievements[208].bCompleted != 1 && !bChecked)
		{
			i = aChecks.Length;
			aChecks.Insert(i, 1);
			aChecks[i] = steamID;

			Log("GIMLI FIX: Checking -" @ userName @ "id=" $ steamID);

			if (SteamWebApi == None)
				SteamWebApi = Spawn(class'KFSteamWebApiNew', self);

			SteamWebApi.AchievementReport = SteamStats.OnAchievementReport;
			SteamWebApi.steamName = userName;
			SteamWebApi.GetAchievements(steamID);
		}
	}
}

DefaultProperties
{
	GroupName="KF-GimliMut"
	FriendlyName="Achievement Fix: Gimli That Axe!"
	Description="Repair Gimli That Axe! achievement on server-side|Get the Not-a-war-hammer Achievement in Dwarfs!? F2P|Created by Heatray, 31.08.2020, v1.2"
}
