//---------------------------------------------------------------------------------------
//  FILE:    UIScreenlistenerAvengerHUD_LEBPortrait.uc
//  AUTHOR:  LeaderEnemyBoss
//  PURPOSE: Hook for MCM
//---------------------------------------------------------------------------------------

class UIScreenlistenerMCM_LEBPortrait extends UIScreenListener config(LEBPortrait);

`include(ModConfigMenuAPI/MCM_API_Includes.uci)
`include(ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config int CONFIG_VERSION;

var config int CameraDistance;
var config int CameraFOV;
var config int BGIndex;
var config bool bAllowTint;
var config int TintIndex1;
var config int TintIndex2;
var config bool bRandomBG;

var localized string strModTitle;
var localized string strPageTitle;
var localized string strSettingsTitle;
var localized string strDistance;
var localized string strFOV;
var localized string strButtonEdit;

var bool bSaveGS;
var int ColorState;

event OnInit(UIScreen Screen)
{
	if (MCM_API(Screen) != none)
	{		
		`MCM_API_Register(Screen, ClientModCallback);
	}
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local MCM_API_SettingsGroup Group;
    
	bSaveGS = false;
	If (Gamemode == eGameMode_Strategy)
	{
		bSaveGS = true;
	}

    LoadSavedSettings();
    
    Page = ConfigAPI.NewSettingsPage(strModTitle);
    Page.SetPageTitle(strPageTitle);
    Page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);
    
    Group = Page.AddGroup('Group1', strSettingsTitle);
	Group.AddSlider('distance', strDistance, "", 25, 100, 5, CameraDistance, , DistanceSaveHandler);
    Group.AddSlider('fov', strFOV, "", 10, 100, 5, CameraFOV, , FOVSaveHandler);

	Group = Page.AddGroup('Group2', class'UIPhotoboothBase'.default.m_CategoryBackgroundOptions);
	Group.AddCheckbox('randombg', class'UIPhotoboothBase'.default.m_CategoryRandom, "", bRandomBG, , CheckboxRandomHandler);
	Group.AddDropdown('ddbg', class'UIPhotoboothBase'.default.m_CategoryBackground, "", GetBackgrounds(), GetBackgroundByIndex(BGIndex), , ddBGHandler).SetEditable(!bRandomBG);
	Group.AddCheckbox('enabletint', class'UIPhotoboothBase'.default.m_CategoryToggleBackgroundTint, "", bAllowTint, , CheckboxTintHandler).SetEditable(!bRandomBG);
	Group.AddButton('color1', class'UIPhotoboothBase'.default.m_CategoryBackgroundTint1, "", strButtonEdit, Color1Handler).SetEditable(bAllowTint && !bRandomBG);
	Group.AddButton('color2', class'UIPhotoboothBase'.default.m_CategoryBackgroundTint2, "", strButtonEdit, Color2Handler).SetEditable(bAllowTint && !bRandomBG);
	
    Page.ShowSettings();
}

static function string GetBackgroundByIndex(int Index)
{
	If (`PHOTOBOOTH.m_arrBackgroundOptions.length <= Index) return `PHOTOBOOTH.m_arrBackgroundOptions[0].BackgroundDisplayName;
	
	return `PHOTOBOOTH.m_arrBackgroundOptions[Index].BackgroundDisplayName;
}

function array<string> GetBackgrounds()
{
	local array<string> outBackgrounds;
	local BackgroundPosterOptions BackGroundOption;
	
	outBackgrounds.Length = 0;

	foreach `PHOTOBOOTH.m_arrBackgroundOptions(BackGroundOption)
	{
		If (BackGroundOption.UsableByTeam == ePBT_ALL || BackGroundOption.UsableByTeam == ePBT_XCOM) outBackgrounds.AddItem(BackGroundOption.BackgroundDisplayName);
	}

	return outBackgrounds;
}

//load current saved settings
`MCM_CH_VersionChecker(class'LEBPortrait_Defaults'.default.VERSION,CONFIG_VERSION)

simulated function LoadSavedSettings()
{
    CameraDistance = `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.CameraDistance, CameraDistance);
	CameraFOV = `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.CameraFOV, CameraFOV);
	BGIndex = `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.BGIndex, BGIndex);
	bAllowTint = `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.bAllowTint, bAllowTint);
	TintIndex1 = `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.TintIndex1, TintIndex1);
	TintIndex2 = `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.TintIndex2, TintIndex2);
	bRandomBG = `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.bRandomBG, bRandomBG);
}

///////////
// Reset //
///////////
simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	local MCM_API_SettingsGroup Group;
	local MCM_API_Setting setting;
	local MCM_API_Slider slider;
	local MCM_API_Dropdown DropDown;
	local MCM_API_Checkbox Checkbox;
	local UIScreen Screen;

	//get Screen and play sound
	foreach `SCREENSTACK.Screens(Screen)
	{
		if(Screen.IsA('MCM_OptionsScreen')) break;
	}
	Screen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);

	//reset Variables
	CameraDistance = class'LEBPortrait_Defaults'.default.CameraDistance;
	CameraFOV = class'LEBPortrait_Defaults'.default.CameraFOV;
	BGIndex = class'LEBPortrait_Defaults'.default.BGIndex;
	bAllowTint = class'LEBPortrait_Defaults'.default.bAllowTint;
	TintIndex1 = class'LEBPortrait_Defaults'.default.TintIndex1;
	TintIndex2 = class'LEBPortrait_Defaults'.default.TintIndex2;
	bRandomBG = class'LEBPortrait_Defaults'.default.bRandomBG;

	//Reset settings
	Group = Page.GetGroupByName('Group1'); //Distance&FOV
	setting = Group.GetSettingByName('distance');
	slider = MCM_API_Slider(setting);
	slider.SetValue(CameraDistance, true);
	setting = Group.GetSettingByName('fov');
	slider = MCM_API_Slider(setting);
	slider.SetValue(CameraFOV, true);
	Group = Page.GetGroupByName('Group2'); //backgroundstuff
	setting = Group.GetSettingByName('ddbg');
	DropDown = MCM_API_Dropdown(setting);
	Dropdown.SetValue(GetBackgroundByIndex(BGIndex), true);
	setting = Group.GetSettingByName('enabletint');
	Checkbox = MCM_API_Checkbox(setting);
	Checkbox.SetValue(bAllowTint, false);
	setting = Group.GetSettingByName('randombg');
	Checkbox = MCM_API_Checkbox(setting);
	Checkbox.SetValue(bRandomBG, false);
}

//////////////
// Handlers //
//////////////

//Distance&FOV
`MCM_API_BasicSliderSaveHandler(DistanceSaveHandler, CameraDistance)
`MCM_API_BasicSliderSaveHandler(FOVSaveHandler, CameraFOV)
//Background
simulated function ddBGHandler(MCM_API_Setting _Setting, string _SettingValue) 
{
	local int idx;
	local BackgroundPosterOptions BackGroundOption;
	
	foreach `PHOTOBOOTH.m_arrBackgroundOptions(BackGroundOption, idx)
	{
		If (BackGroundOption.BackgroundDisplayName == _SettingValue) break;
	}

	BGIndex = idx;
}
//Backgroundcolor
simulated function CheckboxRandomHandler(MCM_API_Setting _Setting, bool _SettingValue) 
{
	bRandomBG = _SettingValue;
	_Setting.GetParentGroup().GetSettingByName('color1').SetEditable(!_SettingValue && bAllowTint);
	_Setting.GetParentGroup().GetSettingByName('color2').SetEditable(!_SettingValue && bAllowTint);
	_Setting.GetParentGroup().GetSettingByName('ddbg').SetEditable(!_SettingValue);
	_Setting.GetParentGroup().GetSettingByName('enabletint').SetEditable(!_SettingValue);
}
simulated function CheckboxTintHandler(MCM_API_Setting _Setting, bool _SettingValue) 
{
	bAllowTint = _SettingValue;
	_Setting.GetParentGroup().GetSettingByName('color1').SetEditable(_SettingValue && !bRandomBG);
	_Setting.GetParentGroup().GetSettingByName('color2').SetEditable(_SettingValue && !bRandomBG);
}
`MCM_API_BasicButtonHandler(Color1Handler)
{
	ColorState = 1;
	SpawnColorPanel();
}
`MCM_API_BasicButtonHandler(Color2Handler)
{
	ColorState = 2;
	SpawnColorPanel();
}

simulated function SpawnColorPanel()
{
	local UIScreen Screen;
	local UIColorSelector ColorSelector;
	local array<UIPanel> ColorSelectors;
	local UIBGBox BG;

	foreach `SCREENSTACK.Screens(Screen)
	{
		if(Screen.IsA('MCM_OptionsScreen')) break;
	}

	Screen.GetChildrenOfType(class'UIColorSelector', ColorSelectors);

	If(ColorSelectors.length == 0)
	{
		BG = Screen.Spawn(class'UIBGBox', Screen);
		BG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
		BG.InitBG('LEBColorBG', 925, 145, 490, 735);
		BG.bAnimateOnInit = false;
		BG.bIsNavigable = false;
		BG.bShouldPlayGenericUIAudioEvents = false;
		BG.Show();

		ColorSelector = Screen.Spawn(class'UIColorSelector', Screen);
		ColorSelector.InitColorSelector('LEBColor', 930, 160, 515, 740, `PHOTOBOOTH.m_FontColors, , SetColor, ColorState == 1 ? TintIndex1 : TintIndex2);
		ColorSelector.Show();
	}
	else
	{
		ColorSelector = UIColorSelector(ColorSelectors[0]);
		ColorSelector.InitialSelection = ColorState == 1 ? TintIndex1 : TintIndex2;
		ColorSelector.SetInitialSelection();
	}
}

function SetColor(int iColorIndex)
{
	local UIScreen Screen;

	If (ColorState == 1) TintIndex1 = iColorIndex;
	If (ColorState == 2) TintIndex2 = iColorIndex;

	foreach `SCREENSTACK.Screens(Screen)
	{
		if(Screen.IsA('MCM_OptionsScreen')) break;
	}

	Screen.GetChildByName('LEBColorBG').Remove();
	Screen.GetChildByName('LEBColor').Remove();
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    local XComGameState_LEBPortrait LEBPState;
	local XComGameState NewGameState;
	
	//`LEBMSG("New Values:" @CameraDistance @CameraFOV);
	
	self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
	
	if (bSaveGS)
	{
		X2Photobooth_StrategyAutoGen_LEBPortrait(`HQPRES.GetPhotoboothAutoGen()).UpdateDistance(); //Update the default distance in case anything uses this
		class'UIScreenlistenerAvengerHUD_LEBPortrait'.static.UpdateHeadshots(); //request update for headshots
	
		//Store current settings in a gamestate, create a new one if necessary
		LEBPState = XComGameState_LEBPortrait(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_LEBPortrait', true));
		If (LEBPState == none) //create new state with current values when there is none (new game/first use of mod) and issue an update
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating LEBPState");
			LEBPState = XComGameState_LEBPortrait(NewGameState.CreateStateObject(class'XComGameState_LEBPortrait'));
			NewGameState.AddStateObject(LEBPState);
			`XCOMHISTORY.AddGameStateToHistory(NewGameState);
			LEBPState = XComGameState_LEBPortrait(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_LEBPortrait', true));
		}
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating LEBPState");
		LEBPState = XComGameState_LEBPortrait(NewGameState.ModifyStateObject(class'XComGameState_LEBPortrait', LEBPState.ObjectID));
		LEBPState.CameraDistance = CameraDistance;
		LEBPState.CameraFOV = CameraFOV;
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}


defaultproperties
{
    ScreenClass = none;
}