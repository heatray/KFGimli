class KFSteamWebApiFix extends KFSteamWebApi;

var string steamName;
var string achievementName;
var string jsonSuccess;
var string jsonAchieved;

var ROBufferedTCPLinkFix myLinkFix;

protected function ROBufferedTCPLinkFix CreateNewLinkFix()
{
	local class<ROBufferedTCPLinkFix> NewLinkClass;
	local ROBufferedTCPLinkFix NewLink;

	if (LinkClassName != "")
		NewLinkClass = class<ROBufferedTCPLinkFix>(DynamicLoadObject(LinkClassName, class'Class'));

	if (NewLinkClass != None)
		NewLink = Spawn(NewLinkClass);

	NewLink.ResetBuffer();

	return NewLink;
}

function GetAchievements(string steamIDIn)
{
	steamID = steamIDIn;
	playerStats = "";

	if(myLinkFix == None)
		myLinkFix = CreateNewLinkFix();

	if(myLinkFix != None)
	{
		myLinkFix.ServerIpAddr.Port = 0;

		sendGet = true;
		myLinkFix.Resolve(steamAPIAddr);  // NOTE: This is a non-blocking operation

		SetTimer(0.25, true);
	}
}

event Timer()
{
	local string command;
	local bool bSuccess;

	if (myLinkFix != None)
	{
		if (myLinkFix.ServerIpAddr.Port != 0)
		{
			if (myLinkFix.IsConnected())
			{
				if (sendGet)
				{
					command = getRequestLeft$appid$getRequestSteamID$steamID$getRequestRight$myLinkFix.CRLF$"Host: "$steamAPIAddr$myLinkFix.CRLF$myLinkFix.CRLF;
					myLinkFix.SendCommand(command);

					pageWait = true;
					myLinkFix.WaitForCount(1,20,1); // 20 sec timeout
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

		if (myLinkFix.PeekChar() != 0)
		{
			pageWait = false;
			playerStats = myLinkFix.InputBuffer;
			bSuccess = (InStr(playerStats, jsonSuccess) != -1);

			if (bSuccess)
			{
				Log("webapi EOF reached", 'DevNet');
			}
			else
			{
				Log("GIMLI FIX: Failed for" @ steamName @ "id=" $ steamID);
				Log("webapi*********** still need to wait", 'DevNet');
				return;
			}

			Log(playerStats, 'DevNet');
			Log("webapi********playerstats", 'DevNet');
			HasAchievement(achievementName);

			myLinkFix.DestroyLink();
			myLinkFix = none;

			return;
		}
	}

	if (myRetryCount >= myRetryMax)
	{
		Log("GIMLI FIX: Too Many Retries" @ steamName @ "id=" $ steamID);
		myLinkFix.DestroyLink();
		myLinkFix = none;
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
		Log("GIMLI FIX: Unlocking for" @ steamName @ "id=" $ steamID);
		return true;
	}

	Log("GIMLI FIX: Sorry for" @ steamName @ "id=" $ steamID);
	return false;
}

DefaultProperties
{
	steamName="Player"
	achievementName="NotAWarhammer"
	jsonSuccess="\"success\":true"
	jsonAchieved="\"apiname\":\"NotAWarhammer\",\"achieved\":1"
	myRetryMax=5

	LinkClassName="KFGimli.ROBufferedTCPLinkFix"
}
