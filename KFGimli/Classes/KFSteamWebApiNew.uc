class KFSteamWebApiNew extends KFSteamWebApi;

var string steamName;
var string achievementName;
var string jsonSuccess;
var string jsonPrivate;
var string jsonAchieved;

event Timer()
{
	local string command;

	if (myLink != None)
	{
		if (myLink.ServerIpAddr.Port != 0)
		{
			if (myLink.IsConnected())
			{
				if (sendGet)
				{
					command = getRequestLeft$appid$getRequestSteamID$steamID$getRequestRight$myLink.CRLF$"Host: "$steamAPIAddr$myLink.CRLF$myLink.CRLF;
					myLink.SendCommand(command);

					pageWait = true;
					myLink.WaitForCount(1,20,1); // 20 sec timeout
					sendGet = false;
				}
			}
			else
			{
				if (sendGet)
				{
					myRetryCount++;
					Log("GIMLI FIX: Could Not Connect " $ myRetryCount $ "/" $ myRetryMax);
				}
			}
		}

		if (myLink.PeekChar() != 0)
		{
			pageWait = false;
			playerStats = myLink.InputBuffer;

			if (InStr(playerStats, jsonSuccess) != -1)
			{
				Log("webapi EOF reached", 'DevNet');
			}
			else
			{
				if (InStr(playerStats, jsonPrivate) != -1)
					Log("GIMLI FIX: Not Public -" @ steamName @ "id=" $ steamID);
				else
					Log("GIMLI FIX: Failed -" @ steamName @ "id=" $ steamID);

				Log("webapi*********** still need to wait", 'DevNet');
				return;
			}

			Log(playerStats, 'DevNet');
			Log("webapi********playerstats", 'DevNet');
			HasAchievement(achievementName);

			myLink.DestroyLink();
			myLink = none;

			return;
		}
	}

	if (myRetryCount >= myRetryMax)
	{
		Log("GIMLI FIX: Too Many Retries" @ steamName @ "id=" $ steamID);
		myLink.DestroyLink();
		myLink = none;
		return;
	}
	else
	{
		SetTimer(1, false);
	}
}

function bool HasAchievement(string achievement)
{
	local bool bCompleted;

	bCompleted = (InStr(playerStats, jsonAchieved) != -1);

	AchievementReport(bCompleted, achievement, appID, steamID);

	if (bCompleted)
	{
		Log("GIMLI FIX: Unlocking -" @ steamName @ "id=" $ steamID);
		return true;
	}

	Log("GIMLI FIX: Not Achieved -" @ steamName @ "id=" $ steamID);
	return false;
}

DefaultProperties
{
	steamName="Player"
	achievementName="NotAWarhammer"
	jsonSuccess="\"success\":true"
	jsonPrivate="\"error\":\"Profile is not public\""
	jsonAchieved="\"apiname\":\"NotAWarhammer\",\"achieved\":1"
	myRetryMax=5

	LinkClassName="KFGimli.ROBufferedTCPLinkNoSteam"
}
