//---------------------------------------------------------------------------------------
//  FILE:    X2Photobooth_StrategyAutoGen_LEBPortrait.uc
//  AUTHOR:  LeaderEnemyBoss
//  PURPOSE: Override for X2Photobooth_StrategyAutoGen to provide configurable distance and FOV
//---------------------------------------------------------------------------------------

class X2Photobooth_StrategyAutoGen_LEBPortrait extends X2Photobooth_StrategyAutoGen;

`include(ModConfigMenuAPI/MCM_API_Includes.uci)
`include(ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

//MCM stuff
`MCM_CH_VersionChecker(class'LEBPortrait_Defaults'.default.VERSION,class'UIScreenlistenerMCM_LEBPortrait'.default.CONFIG_VERSION)

function int GetCameraDistance()
{
    return `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.CameraDistance,class'UIScreenlistenerMCM_LEBPortrait'.default.CameraDistance);
}
function int GetCameraFOV()
{
    return `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.CameraFOV,class'UIScreenlistenerMCM_LEBPortrait'.default.CameraFOV);
}
function int GetBGIndex()
{
    return `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.BGIndex,class'UIScreenlistenerMCM_LEBPortrait'.default.BGIndex);
}
function bool RandomBG()
{
    return `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.bRandomBG,class'UIScreenlistenerMCM_LEBPortrait'.default.bRandomBG);
}

function Init()
{
	super.Init();
	UpdateDistance();
}

function UpdateDistance()
{
	DefaultCameraDistance = GetCameraDistance();

	//`LEBMSG("UpdateDistance()" @DefaultCameraDistance @default.DefaultCameraDistance);
}

function AddHeadShotRequest(StateObjectReference UnitRef, int SizeX, int SizeY, delegate<OnAutoGenPhotoFinished> Callback, optional X2SoldierPersonalityTemplate Personality, optional bool bFlushPendingRequests = false, optional bool bHighPriority = false)
{
	local int i;
	local AutoGenPhotoInfo LocAutoGenInfo;
	local XComGameState_Unit Unit;
	local UnitToCameraDistance LocUnitToCameraDist;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
	
	//LEB: Added check for empty units (happens sometimes and clogs the queue)
	If (Unit == none) return;
	//`LEBMSG("AddHeadShotRequest" @UnitRef.ObjectID @Unit.GetFullName() @Unit);

	if (`XENGINE.m_kPhotoManager.HeadshotExistsAndIsCurrent(AutoGenSettings.CampaignID, UnitRef.ObjectID, Unit))
	{
		if (Callback != none)
		{
			Callback(UnitRef);
		}

		return;
	}

	// Check for existing request
	for (i = 0; i < arrAutoGenRequests.Length; ++i)
	{
		if (arrAutoGenRequests[i].UnitRef.ObjectID == UnitRef.ObjectID && arrAutoGenRequests[i].TextLayoutState == ePBTLS_HeadShot)
		{
			if (Callback != none)
			{
				arrAutoGenRequests[i].FinishedDelegates.AddItem(Callback);
			}


			//LEB: Update LocAutoGenInfo with new distance (this often happens if a user trys a bunch of different settings in a row)
			if (bHighPriority && i != 0)
			{
				LocAutoGenInfo = arrAutoGenRequests[i];
				
				LocAutoGenInfo.CameraDistance = DefaultCameraDistance;
				foreach arrUnitToCameraDistances(LocUnitToCameraDist)
				{
					if (LocUnitToCameraDist.UnitTemplateName == Unit.GetMyTemplateName())
					{
						LocAutoGenInfo.CameraDistance = LocUnitToCameraDist.CameraDistance + (DefaultCameraDistance);
						break;
					}
				}
		
				arrAutoGenRequests.Remove(i, 1);
				arrAutoGenRequests.InsertItem(0, LocAutoGenInfo);
			}
			//`LEBMSG("duplicate request" @Unit.GetFullName());
			return;
		}
	}

	// Add new request
	LocAutoGenInfo.TextLayoutState = ePBTLS_HeadShot;
	LocAutoGenInfo.UnitRef = UnitRef;
	LocAutoGenInfo.SizeX = 512;
	LocAutoGenInfo.SizeY = 512;

	LocAutoGenInfo.CameraDistance = DefaultCameraDistance;

	//LEB: Add custom Distance to it (else photos may look weird due to low fov)
	foreach arrUnitToCameraDistances(LocUnitToCameraDist)
	{
		if (LocUnitToCameraDist.UnitTemplateName == Unit.GetMyTemplateName())
		{
			LocAutoGenInfo.CameraDistance = LocUnitToCameraDist.CameraDistance + (DefaultCameraDistance);
			break;
		}
	}

	if (Callback != none)
	{
		LocAutoGenInfo.FinishedDelegates.AddItem(Callback);
	}

	if (Personality == none)
	{
		Personality = Unit.GetPhotoboothPersonalityTemplate();
	}
	LocAutoGenInfo.AnimName = Personality.IdleAnimName;
	
	// LEB: Special Case for spark idle
	If (Unit.GetMyTemplateName() == 'SparkSoldier')	LocAutoGenInfo.AnimName = 'Idle_Normal_TG01A';
	
	if (bHighPriority)
	{
		arrAutoGenRequests.InsertItem(0, LocAutoGenInfo);
	}
	else
	{
		arrAutoGenRequests.AddItem(LocAutoGenInfo);
	}
}

// LEB: use custom FOV instead of fixed 80
function TakePhoto()
{
	local XComGameState_Unit Unit;
	local XComGameState_AdventChosen ChosenState;
	local SoldierBond BondData;
	local StateObjectReference BondmateRef;
	local array<BackgroundPosterOptions> arrBackgrounds;

	// Set things up for the next photo and queue it up to the photobooth.
	if (arrAutoGenRequests.Length > 0)
	{
		ExecutingAutoGenRequest = arrAutoGenRequests[0];

		AutoGenSettings.PossibleSoldiers.Length = 0;
		AutoGenSettings.PossibleSoldiers.AddItem(ExecutingAutoGenRequest.UnitRef);
		AutoGenSettings.TextLayoutState = ExecutingAutoGenRequest.TextLayoutState;
		AutoGenSettings.HeadShotAnimName = '';
		AutoGenSettings.CameraPOV.FOV = class'UIArmory_Photobooth'.default.m_fCameraFOV;
		AutoGenSettings.BackgroundDisplayName = class'UIPhotoboothBase'.default.m_strEmptyOption;
		SetFormation("Solo");

		switch (ExecutingAutoGenRequest.TextLayoutState)
		{
		case ePBTLS_DeadSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Full Frontal";
			break;
		case ePBTLS_PromotedSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Full Frontal";
			break;
		case ePBTLS_BondedSoldier:
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ExecutingAutoGenRequest.UnitRef.ObjectID));

			if (Unit.HasSoldierBond(BondmateRef, BondData))
			{
				AutoGenSettings.PossibleSoldiers.AddItem(BondmateRef);
				AutoGenSettings.CameraPresetDisplayName = "Full Frontal";

				SetFormation("Duo");
			}
			else
			{
				arrAutoGenRequests.Remove(0, 1);
				return;
			}
			break;
		case ePBTLS_CapturedSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Captured";

			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ExecutingAutoGenRequest.UnitRef.ObjectID));
			ChosenState = XComGameState_AdventChosen(`XCOMHISTORY.GetGameStateForObjectID(Unit.ChosenCaptorRef.ObjectID));
			AutoGenSettings.BackgroundDisplayName = GetChosenBackgroundName(ChosenState);
			break;
		case ePBTLS_HeadShot:
			AutoGenSettings.CameraPresetDisplayName = "HeadshotLEB";

			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ExecutingAutoGenRequest.UnitRef.ObjectID));
			// LEB: Special camera preset for sparks, since they are a bit offcenter otherwise
			If (Unit.GetMyTemplateName() == 'SparkSoldier') AutoGenSettings.CameraPresetDisplayName = "HeadshotLEBSpark";
			//`LEBMSG("Taking photo for" @Unit.GetFullName() @AutoGenSettings.BackgroundDisplayName);

			AutoGenSettings.BackgroundDisplayName = class'UIScreenlistenerMCM_LEBPortrait'.static.GetBackgroundByIndex(GetBGIndex());
			If (randomBG())
			{
				`PHOTOBOOTH.GetBackgrounds(arrBackgrounds, ePBT_XCOM);
				AutoGenSettings.BackgroundDisplayName = arrBackgrounds[`SYNC_RAND(arrBackgrounds.length)].BackgroundDisplayName;
			}

			AutoGenSettings.SizeX = ExecutingAutoGenRequest.SizeX;
			AutoGenSettings.SizeY = ExecutingAutoGenRequest.SizeY;
			AutoGenSettings.CameraDistance = ExecutingAutoGenRequest.CameraDistance;
			AutoGenSettings.HeadShotAnimName = ExecutingAutoGenRequest.AnimName;
			AutoGenSettings.CameraPOV.FOV = GetCameraFOV();
			break;
		}

		`PHOTOBOOTH.SetAutoGenSettings(AutoGenSettings, PhotoTaken);
	}
	else
	{
		m_bTakePhotoRequested = false;
		Cleanup();
	}
}