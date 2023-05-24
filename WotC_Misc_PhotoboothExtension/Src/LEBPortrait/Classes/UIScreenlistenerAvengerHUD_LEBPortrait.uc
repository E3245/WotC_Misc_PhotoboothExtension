//---------------------------------------------------------------------------------------
//  FILE:    UIScreenlistenerAvengerHUD_LEBPortrait.uc
//  AUTHOR:  LeaderEnemyBoss
//  PURPOSE: Hook for updating old headshots
//---------------------------------------------------------------------------------------

class UIScreenlistenerAvengerHUD_LEBPortrait extends UIScreenListener;

`define LEBMSG(msg, tag) class'Helpers'.static.OutputMsg( `msg , 'LEBPortrait')

event OnInit(UIScreen Screen)
{
	local XComGameState_LEBPortrait LEBPState;
	local XComGameState NewGameState;
	
	LEBPState = XComGameState_LEBPortrait(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_LEBPortrait', true));
	
	If (LEBPState == none) //create new state with current values when there is none (new game/first use of mod) and issue an update
	{
		//`LEBMSG("found no gamestate, creating new one");
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating LEBPState");
		LEBPState = XComGameState_LEBPortrait(NewGameState.CreateStateObject(class'XComGameState_LEBPortrait'));
		NewGameState.AddStateObject(LEBPState);
		`XCOMHISTORY.AddGameStateToHistory(NewGameState);

		LEBPState = XComGameState_LEBPortrait(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_LEBPortrait', true));
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating LEBPState");
		LEBPState = XComGameState_LEBPortrait(NewGameState.ModifyStateObject(class'XComGameState_LEBPortrait', LEBPState.ObjectID));
		LEBPState.CameraDistance = X2Photobooth_StrategyAutoGen_LEBPortrait(`HQPRES.GetPhotoboothAutoGen()).GetCameraDistance();
		LEBPState.CameraFOV = X2Photobooth_StrategyAutoGen_LEBPortrait(`HQPRES.GetPhotoboothAutoGen()).GetCameraFOV();
		//`LEBMSG("Stored values:" @LEBPState.CameraDistance @LEBPState.CameraFOV);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		UpdateHeadshots();
	}
	else //update all headshots if settings got changed (e.g. user changed settings while playing a different save)
	{
		If (LEBPState.CameraDistance != X2Photobooth_StrategyAutoGen_LEBPortrait(`HQPRES.GetPhotoboothAutoGen()).GetCameraDistance() ||
			LEBPState.CameraFOV != X2Photobooth_StrategyAutoGen_LEBPortrait(`HQPRES.GetPhotoboothAutoGen()).GetCameraFOV())
		{
			UpdateHeadshots();
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating LEBPState");
			LEBPState = XComGameState_LEBPortrait(NewGameState.ModifyStateObject(class'XComGameState_LEBPortrait', LEBPState.ObjectID));
			LEBPState.CameraDistance = X2Photobooth_StrategyAutoGen_LEBPortrait(`HQPRES.GetPhotoboothAutoGen()).GetCameraDistance();
			LEBPState.CameraFOV = X2Photobooth_StrategyAutoGen_LEBPortrait(`HQPRES.GetPhotoboothAutoGen()).GetCameraFOV();
			//`LEBMSG("Stored values differ from current values, updating headshots to ..." @LEBPState.CameraDistance @LEBPState.CameraFOV);
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}
	}
}
	
static function UpdateHeadshots()
{
	local int CampaignIndex;
	local int PosterIndex;
	local XComGameState_Unit Unit;
	local StateObjectReference UnitRef;
	//local Texture2D StaffPicture;
	local XComGameState_CampaignSettings SettingsState;

	//class'Helpers'.static.OutputMsg("======================================================================================");

	//give all stored headshots an arbitrary cosmetic-name, so the game thinks they need and update
	for (CampaignIndex = 0; CampaignIndex < `XENGINE.m_kPhotoManager.m_PhotoDatabase.Length; ++CampaignIndex)
	{
		for (PosterIndex = 0; PosterIndex < `XENGINE.m_kPhotoManager.m_PhotoDatabase[CampaignIndex].HeadShots.Length; ++PosterIndex)
		{
			`XENGINE.m_kPhotoManager.m_PhotoDatabase[CampaignIndex].HeadShots[PosterIndex].nmHead = 'LEBTEST';
		}
	}

	SettingsState = XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));

	//Delete old Headshots
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', Unit )
	{
		if(Unit.isSoldier() || Unit.IsEngineer() || Unit.IsScientist()) 
		{
			UnitRef = Unit.GetReference();
			`XENGINE.m_kPhotoManager.HeadshotExistsAndIsCurrent(SettingsState.GameIndex, UnitRef.ObjectID, Unit);

			//StaffPicture = `XENGINE.m_kPhotoManager.GetHeadshotTexture(SettingsState.GameIndex, UnitRef.ObjectID, 512, 512);
//
			////class'Helpers'.static.OutputMsg("LEBPortrait Units:" @Unit.GetFullName());
//
			//if(StaffPicture != none)
			//{
				////class'Helpers'.static.OutputMsg("Unit Ids:" @Unit.ObjectID @UnitRef.ObjectID);
//
				//`HQPRES.GetPhotoboothAutoGen().AddHeadShotRequest(UnitRef, 512, 512, OnSoldierHeadCaptureFinished);
				//`HQPRES.GetPhotoboothAutoGen().RequestPhotos();
			//}
		}
	}
}

//static function UpdateHeadshot(XComGameState_Unit Unit)
//{
	//local StateObjectReference UnitRef;
//
	//UnitRef = Unit.GetReference();
	//
	//`HQPRES.GetPhotoboothAutoGen().AddHeadShotRequest(UnitRef, 512, 512, OnSoldierHeadCaptureFinished);
	//`HQPRES.GetPhotoboothAutoGen().RequestPhotos();
//}

//function OnSoldierHeadCaptureFinished(StateObjectReference UnitRef)
//{
	//local XComGameState_Unit Unit;
//
	//Unit = XComGameState_Unit( `XCOMHISTORY.GetGameStateForObjectID( UnitRef.ObjectID ) );
	//`LEBMSG("LEBPortrait requested Headshot for" @Unit.GetFullName());
//}



defaultproperties
{
	ScreenClass=UIAvengerHUD;
}