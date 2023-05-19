//
// DESC: Handles most of UIPhotobooth logic including sending signals
//		 via EL for other screens.
//
class UIPhotoboothExtendedMaster extends Actor;

var localized string m_CategoryObjects;
var localized string m_CategoryLightSources;
var localized string m_CategoryExtendedOptions;
var localized string m_CategoryDisableUI;

var localized string m_DestructiveAction_Randomize_Title;
var localized string m_DestructiveAction_Randomize_Body;

var localized string m_DestructiveAction_Reset_Title;
var localized string m_DestructiveAction_Reset_Body;

var localized string m_PickNewSoldier;

// Unit Editor
var localized string m_UnitEditor_SelectedSoldier;
var localized string m_UnitEditor_Pose;
var localized string m_UnitEditor_Animation;
var localized string m_UnitEditor_ToggleFootIK;
var localized string m_UnitEditor_ToggleLeftHandIK;
var localized string m_UnitEditor_HideUnit;

// Position/Rotation/Scale Editor
var localized string m_Editor_Step;

var localized string m_Editor_Position_X;
var localized string m_Editor_Position_Y;
var localized string m_Editor_Position_Z;
var localized string m_Editor_Position_Reset;

var localized string m_Editor_Rotation_Pitch;
var localized string m_Editor_Rotation_Yaw;
var localized string m_Editor_Rotation_Roll;
var localized string m_Editor_Rotation_Reset;

var localized string m_Editor_Scale_X;
var localized string m_Editor_Scale_Reset;

// Objects Editor
var localized string m_PrefixObject;
var localized string m_CreateNewObject;

var localized string m_ObjectEditor_SelectedObject;
var localized string m_ObjectEditor_HideObject;
var localized string m_ObjectEditor_DeleteObject;

// Lights Editor
var localized string m_PrefixLight;
var localized string m_CreateNewLight;

var localized string m_LightEditor_Type;

var localized string m_LightEditor_HideLight;
var localized string m_LightEditor_DeleteLight;

var localized string m_LightEditor_Brightness;
var localized string m_LightEditor_HexColor;

var localized string m_LightEditor_Spot_InnerConeAngle;
var localized string m_LightEditor_Spot_OuterConeAngle;

// Effects Editor
var localized string m_PrefixEffect;
var localized string m_CreateNewEffect;

var localized string m_EffectsEditor_SelectedObject;
var localized string m_EffectsEditor_HideObject;
var localized string m_EffectsEditor_DeleteObject;

// Graphics Editor
var localized string m_Graphics_PrefixTextRandomize_Button;
var localized string m_Graphics_TextRandomize_Button;
var localized string m_Graphics_TextRandomize_IgnoreFormations;

// Extended Options
var localized string m_ExtOptions_MaxUnitCount;
var localized string m_ExtOptions_IgnoreFormationLimits;

var localized string m_ExtOptions_PosterLandscapeSizeX;
var localized string m_ExtOptions_PosterLandscapeSizeY;

// Tooltips
var localized string m_Tooltip_Disabled_MCO;

var EUIPropagandaExtendedScreenType currentScreenState;
var EUIPropagandaExtendedScreenType lastScreenState; //bsg-jedwards (5.1.17) : Adding last state check for list refresh

var X2PhotoboothExtended	PhotoboothEx;

var UIPhotoboothBase		CurrentScreen;

var int				 m_iLastTouchedSoldierIndex;
var int				 m_iLastTouchedTextBox;

var int				 iSelectedObjectDataIndex;
var int				 iSelectedLightDataIndex;
var int				 m_iCurrentModifyingTextBox;

// Editor
var Float				Step;
var int					SliderEditorPos_X_PrevPct;
var int					SliderEditorPos_Y_PrevPct;
var int					SliderEditorPos_Z_PrevPct;

var bool				bMCO_Enabled;

// Graphics
var bool				bRandomizeTextIgnoreFormations;

var delegate<PhotoboothDataStructures.NewObjectLocationCallback>		ObjectLocationFn;

function OnInit(UIPhotoboothBase Screen, delegate<PhotoboothDataStructures.NewObjectLocationCallback> ObjectLocationCallback)
{
	local Vector2D ViewportSize;

	PhotoboothEx = Spawn(class'X2PhotoboothExtended', self);
	PhotoboothEx.ResetPhotoboothEx();

	CurrentScreen = Screen;

	ObjectLocationFn = ObjectLocationCallback;

	class'Engine'.static.GetEngine().GameViewport.GetViewportSize(ViewportSize);

	// Set the default landscape resolution to the player's set resolution
	if (class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeX == 0)
		class'PhotoboothExtendedSettings'.static.SetInt_PosterSizeLandscape_X(ViewportSize.X);

	if (class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeY == 0)
		class'PhotoboothExtendedSettings'.static.SetInt_PosterSizeLandscape_Y(ViewportSize.Y);

	// Make sure this setting is set to off
	if (class'PhotoboothExtendedSettings'.default.bSystemOnly_IsInLandscapeMode)
		class'PhotoboothExtendedSettings'.static.SetBool_System_IsInLandscapeMode(false);

	UIPhotoboothMovie_PE(CurrentScreen.Movie.Pres.GetPhotoboothMovie()).ChangeResolution(800, 1200);

	bMCO_Enabled = `PHOTOBOOTH.IsA('X2PhotoboothReplacement') ? true : false;
}

function UIMechaListItem GetListItem(int ItemIndex, optional bool bDisableItem, optional string DisabledReason)
{
	local UIMechaListItem CustomizeItem;
	local UIPanel Item;

	if (ItemIndex >= CurrentScreen.List.ItemContainer.ChildPanels.Length)
	{
		CustomizeItem = Spawn(class'UIMechaListItem_PhotoboothEx', CurrentScreen.List.itemContainer);
		CustomizeItem.bAnimateOnInit = false;
		CustomizeItem.InitListItem();
	}
	else
	{
		Item = CurrentScreen.List.GetItem(ItemIndex);
		CustomizeItem = UIMechaListItem(Item);
	}

	if (bDisableItem != CustomizeItem.bDisabled)
		CustomizeItem.SetDisabled(bDisableItem, DisabledReason);

	return CustomizeItem;
}

function SetScreenState(EUIPropagandaExtendedScreenType NewScreenState)
{
	lastScreenState		= currentScreenState;
	currentScreenState	= NewScreenState;
}

// When called, will tell the screens to refresh themselves
function TriggerScreenNeedsPopulate()
{
	CurrentScreen.NeedsPopulateData();
}

// Returns the vector calculated by the delegate function
function Vector SetInitialObjectPosition()
{
	return ObjectLocationFn();
}

function OpenTextBoxInputInterface(	string Title, string PreInput, int MaxChars, 
											delegate<UIInputDialogue.TextInputAcceptedCallback> AcceptFn, 
											delegate<UIInputDialogue.TextInputCancelledCallback> CancelledFn, 
											delegate<XComPresentationLayerBase.delActionAccept> VKOnAccept, 
											delegate<XComPresentationLayerBase.delActionCancel> VKOnCancel )
{
	local TInputDialogData kData;

	if( `ISCONSOLE )
	{
		CurrentScreen.Movie.Pres.UIKeyboard( Title, //bsg-jedwards (6.1.17) : Replaced hard-coded text with localized string
			PreInput, 
			VKOnAccept, 
			VKOnCancel,
			false, 
			MaxChars
		);
	}
	else 
	{
		// on PC, we have a real keyboard, so use that instead
		kData.fnCallbackAccepted = AcceptFn;
		kData.fnCallbackCancelled = CancelledFn;
		kData.strTitle = Title;
		kData.iMaxChars = MaxChars;
		kData.strInputBoxText = PreInput;
		CurrentScreen.Movie.Pres.UIInputDialog(kData);
	}
}

function OnCancel()
{
	if (CurrentScreen.bWaitingOnPhoto)
		return;

	switch (currentScreenState)
	{
	case eUIPropagandaType_Base:
		//bsg-hlee (05.12.17): If a picture has not been taken then show the popup.
		if(!CurrentScreen.bHasTakenPicture)
			CurrentScreen.DestructiveActionPopup();
		else //Skip the popup and just go to the cleanup and close of the screen.
			CurrentScreen.OnDestructiveActionPopupExitDialog('eUIAction_Accept');
		//bsg-hlee (05.12.17): End
		break;
	
	case eUIPropagandaType_Soldier:
		CurrentScreen.m_bRotatingPawn = false;
	case eUIPropagandaType_Pose:
		//bsg-jneal (5.16.17): now changing pose on selection change so need to remember initial pose when cancelling menu
		CurrentScreen.List.SetSelectedIndex(CurrentScreen.m_bOriginalSubListIndex);
		CurrentScreen.List.OnSelectionChanged = none;
		//bsg-jneal (5.16.17): end

		SetScreenState(eUIPropagandaType_SoldierEditor);
		break;

	//bsg-jedwards (5.1.17) : Hide color selector if backing out
	//case eUIPropagandaType_GradientColor1:
	//case eUIPropagandaType_GradientColor2:
	//	ColorSelector.Hide();
	//	currentScreenState = eUIPropagandaType_Base;
	//	break;
	//bsg-jedwards (5.1.17) : end

	//bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed
	case eUIPropagandaType_Formation:
	case eUIPropagandaType_Layout:
	case eUIPropagandaType_Filter:
	case eUIPropagandaType_Treatment:
		CurrentScreen.List.SetSelectedIndex(CurrentScreen.m_bOriginalSubListIndex);
		CurrentScreen.List.OnSelectionChanged = none;
	case eUIPropagandaType_SoldierData:
	case eUIPropagandaType_BackgroundOptions:
	case eUIPropagandaType_Graphics:
	// PE: Return to base state
	case eUIPropagandaType_ObjectsList:
	case eUIPropagandaType_LightsList:
	case eUIPropagandaType_ExtendedOptions:
		SetScreenState(eUIPropagandaType_Base);
		break;

	
	case eUIPropagandaType_GradientColor1:
	case eUIPropagandaType_GradientColor2:
		CurrentScreen.ColorSelector.Hide();
		CurrentScreen.SetTextColor(CurrentScreen.m_iPreviousColor);
		SetScreenState(eUIPropagandaType_BackgroundOptions);
		break;

	case eUIPropagandaType_Background:
		CurrentScreen.List.SetSelectedIndex(CurrentScreen.m_bOriginalSubListIndex);
		CurrentScreen.List.OnSelectionChanged = none;
		SetScreenState(eUIPropagandaType_BackgroundOptions);
		break;

	case eUIPropagandaType_TextColor:
		CurrentScreen.ColorSelector.Hide();
		CurrentScreen.SetTextColor(CurrentScreen.m_iPreviousColor);
		SetScreenState(eUIPropagandaType_Graphics);
		break;
	//bsg-jneal (5.23.17): end
	case eUIPropagandaType_TextFont:
	case eUIPropagandaType_Fonts:
		SetScreenState(eUIPropagandaType_Graphics);
		break;
	// PE: Soldier Editor needs to return to Soldier Data
	case eUIPropagandaType_SoldierEditor:
		SetScreenState(eUIPropagandaType_SoldierData);
		break;
	case eUIPropagandaType_ObjectEditor:
		SetScreenState(eUIPropagandaType_ObjectsList);
		break;
	case eUIPropagandaType_PickObjectData:
		SetScreenState(eUIPropagandaType_ObjectEditor);
		break;
	case eUIPropagandaType_LightEditor:
		PhotoboothEx.UpdateLightMeshHelperVisibility(iSelectedLightDataIndex, true);
		SetScreenState(eUIPropagandaType_LightsList);
		break;
	case eUIPropagandaType_LandscapeMode:
		OnExitLandscapeMode();
		SetScreenState(eUIPropagandaType_Base);
		break;
	}

	CurrentScreen.List.ItemContainer.RemoveChildren();
	TriggerScreenNeedsPopulate();
}

// Main menu
function PopulateDefaultList(out int Index)
{
	local array<string> FilterNames;
	local int FilterIndex;

	GetListItem(Index++).UpdateDataValue(CurrentScreen.m_CategoryFormations, `PHOTOBOOTH.m_kFormationTemplate.DisplayName, CurrentScreen.OnClickFormation);

	//GetSoldierData(j, SoldierNames, SoldierIndex);
	GetListItem(Index++).UpdateDataDescription(CurrentScreen.m_CategorySoldiers, CurrentScreen.OnClickSoldiers);

	GetListItem(Index++).UpdateDataDescription(CurrentScreen.m_CategoryBackgroundOptions, CurrentScreen.OnClickBackgroundOptions);

	//GetLayoutNames(LayoutNames);
	GetListItem(Index++).UpdateDataValue(CurrentScreen.m_CategoryLayout, `PHOTOBOOTH.m_currentTextLayoutTemplate.DisplayName, CurrentScreen.OnClickTextLayout);

	GetListItem(Index++).UpdateDataDescription(CurrentScreen.m_CategoryGraphics, CurrentScreen.OnClickGraphics);
	if (CurrentScreen.bChallengeMode)
	{
		GetListItem(Index - 1).SetDisabled(true);
	}
	
	CurrentScreen.GetFirstPassFilterData(FilterNames, FilterIndex);
	GetListItem(Index++).UpdateDataValue(CurrentScreen.m_CategoryFilter, FilterNames[FilterIndex], CurrentScreen.OnClickFirstPassFilter);

	FilterNames.Length = 0;
	CurrentScreen.GetSecondPassFilterData(FilterNames, FilterIndex);
	GetListItem(Index++).UpdateDataValue(CurrentScreen.m_CategoryTreatment, FilterNames[FilterIndex], CurrentScreen.OnClickSecondPassFilter);

	//bsg-jneal (6.26.17): no hide poster on console
	if(!`ISCONSOLE)
	{
		GetListItem(Index++).UpdateDataCheckbox(CurrentScreen.m_CategoryHidePoster, "", `PHOTOBOOTH.PosterElementsHidden(), CurrentScreen.OnHidePoster);
	}
	//bsg-jneal (6.26.17): end

	//bsg-jedwards (5.1.17) : Adds Spinner to the options when using a controller
	if(`ISCONTROLLERACTIVE)
	{
		CurrentScreen.ModeSpinnerVal = CurrentScreen.max_SpinnerVal + 1; //bsg-jedwards (5.6.17) : Sets the spinner to the end of the array by default
		GetListItem(Index++).UpdateDataSpinner(CurrentScreen.m_CategoryCameraPresets, CurrentScreen.m_CameraPresets_Labels[CurrentScreen.ModeSpinnerVal], CurrentScreen.UpdateMode_OnChanged);
	}
	//bsg-jedwards (5.1.17) : end

	GetListItem(Index++).UpdateDataDescription(m_CategoryObjects,			OnObjects);							// PE: Spawns new Objects
	GetListItem(Index++).UpdateDataDescription(m_CategoryLightSources,		OnLightSources);					// PE: Enables manipulation of light sources
	GetListItem(Index++).UpdateDataDescription(m_CategoryExtendedOptions,	OnExtendedOptions);					// PE: Persistent Options
	GetListItem(Index++, !bMCO_Enabled, m_Tooltip_Disabled_MCO).UpdateDataDescription(m_CategoryDisableUI,			OnLandscapeScreenshot);				// PE: Disables UI for widescreen picture taking
																												
	GetListItem(Index++).UpdateDataDescription(CurrentScreen.m_CategoryRandom,			DestructiveActionPopup_Randomize);					// PE: Popup to warn players of data loss
	GetListItem(Index++).UpdateDataDescription(CurrentScreen.m_CategoryReset,			DestructiveActionPopup_Reset);					// PE: Popup to warn players of data loss

	CurrentScreen.List.OnSelectionChanged = CurrentScreen.OnDefaultListChange; //bsg-jneal (5.23.17): saving default list index for better nav
}

function OnObjects()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_ObjectsList);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	TriggerScreenNeedsPopulate();
}

function OnLightSources()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_LightsList);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	TriggerScreenNeedsPopulate();
}

function OnExtendedOptions()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_ExtendedOptions);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	TriggerScreenNeedsPopulate();
}

function OnLandscapeScreenshot()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_LandscapeMode);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	// Force an update
	TriggerScreenNeedsPopulate();

	class'PhotoboothExtendedSettings'.static.SetBool_System_IsInLandscapeMode(true);
}


//
// OnRandomize() Delegate called
//
function DestructiveActionPopup_Randomize()
{
	local TDialogueBoxData kConfirmData;

	kConfirmData.strTitle	= m_DestructiveAction_Randomize_Title;
	kConfirmData.strText	= m_DestructiveAction_Randomize_Body;
	kConfirmData.strAccept	= class'UIUtilities_Text'.default.m_strGenericYes;
	kConfirmData.strCancel	= class'UIUtilities_Text'.default.m_strGenericNo;

	kConfirmData.fnCallback = OnDestructiveActionPopupRandomizeDialog;

	CurrentScreen.Movie.Pres.UIRaiseDialog(kConfirmData);
}

function OnDestructiveActionPopupRandomizeDialog(Name eAction)
{
	if (eAction == 'eUIAction_Accept')
	{
		CurrentScreen.OnRandomize();
	}
}

//
// OnRandomize() Delegate called
//
function DestructiveActionPopup_Reset()
{
	local TDialogueBoxData kConfirmData;


	kConfirmData.strTitle	= m_DestructiveAction_Reset_Title;
	kConfirmData.strText	= m_DestructiveAction_Reset_Body;
	kConfirmData.strAccept	= class'UIUtilities_Text'.default.m_strGenericYes;
	kConfirmData.strCancel	= class'UIUtilities_Text'.default.m_strGenericNo;

	kConfirmData.fnCallback = OnDestructiveActionPopupResetDialog;

	CurrentScreen.Movie.Pres.UIRaiseDialog(kConfirmData);
}

function OnDestructiveActionPopupResetDialog(Name eAction)
{
	if (eAction == 'eUIAction_Accept')
	{
		CurrentScreen.OnReset();
	}
}

//
// Current Soldier List Menu
// 
function PopulateSoldierDataList(out int Index, optional delegate<UIList.OnItemSelectedCallback>  OnSelectionChanged)
{
	local int i, MaxFormationUnits;
	local string SoldierName;

	MaxFormationUnits	= `PHOTOBOOTH.m_kFormationTemplate.NumSoldiers;

	for (i = 0; i < MaxFormationUnits; i++)
	{
		// Default values for every iteration
		SoldierName			= "";

		// Simply generate Soldier 1 to X tabs
		// Insert names if assigned
		if (i < `PHOTOBOOTH.m_arrUnits.Length)
		{
			SoldierName = class'X2Helpers_PhotoboothExtended'.static.GetSoldierNameWithNick(i);
		}

		GetListItem(Index++).UpdateDataValue(CurrentScreen.m_PrefixSoldier@i+1, SoldierName, OnSoldierEditor);
	}

	// Set new delegate for this set only
	// Remember to set this back after returning to any other part of the screen
	CurrentScreen.List.OnSelectionChanged =  OnSelectionChanged; //bsg-jneal (5.23.17): saving default list index for better nav
}

function OnSoldierEditor()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_SoldierEditor);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	TriggerScreenNeedsPopulate();
}

//
// Soldier Editor
//
function PopulateSoldierEditorList(out int Index)
{
	local PoseSoldierData		UnitPoseData;
	local XComGameState_Unit	UnitToEdit;
	local int					AnimIndex;
	local array<String>			AnimNames;
	local bool					bDisabled;

	UnitPoseData	= `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex];
	UnitToEdit		= XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitPoseData.UnitRef.ObjectID));

	`LOG("[" $ GetFuncName() $ "()] Function Called", true, default.class.name);

	// Select Soldier
	GetListItem(Index++).UpdateDataValue(m_UnitEditor_SelectedSoldier,		UnitToEdit.GetName(eNameType_FullNick), OnClickChangeSoldier);

	if (`PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn == none)
		bDisabled = true;

	// Pose
	CurrentScreen.GetAnimationData(m_iLastTouchedSoldierIndex, AnimNames, AnimIndex);
	GetListItem(Index++, bDisabled).UpdateDataValue(m_UnitEditor_Pose,			AnimNames[AnimIndex],	OnChoosePose);

	// Animation
//	GetListItem(Index++).UpdateDataValue(m_UnitEditor_Animation,	"NOT IMPLEMENTED",		OnAnimation);

	// Step
	GetListItem(Index++, bDisabled).UpdateDataSpinner(m_Editor_Step, string(Step),	OnStepSpinnerChanged, OnStepSpinnerClicked);

	
	// Position X
	// Position Y
	// Position Z
	UIMechaListItem_PhotoboothEx(GetListItem(Index++, bDisabled)).UpdateDataSliderPosition(m_Editor_Position_X, string(UnitPoseData.ActorPawn.Location.X), 50,	OnPositionXSpinnerClicked_Soldier, PositionSliderChanged_X_Soldier);
	UIMechaListItem_PhotoboothEx(GetListItem(Index++, bDisabled)).UpdateDataSliderPosition(m_Editor_Position_Y, string(UnitPoseData.ActorPawn.Location.Y), 50,	OnPositionYSpinnerClicked_Soldier, PositionSliderChanged_Y_Soldier);
	UIMechaListItem_PhotoboothEx(GetListItem(Index++, bDisabled)).UpdateDataSliderPosition(m_Editor_Position_Z, string(UnitPoseData.ActorPawn.Location.Z), 50,	OnPositionZSpinnerClicked_Soldier, PositionSliderChanged_Z_Soldier);

	// Rotation Pitch
	GetListItem(Index++, bDisabled).UpdateDataSlider(m_Editor_Rotation_Pitch,	string(abs(UnitPoseData.ActorPawn.Rotation.Pitch * UnrRotToDeg)),
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(UnitPoseData.ActorPawn.Rotation.Pitch)), OnRotationPitchClicked_Soldier,
											RotateSoldierSliderPitch);
	// Rotation Roll
	GetListItem(Index++, bDisabled).UpdateDataSlider(m_Editor_Rotation_Yaw,	string(abs(UnitPoseData.ActorPawn.Rotation.Yaw * UnrRotToDeg)),	
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(UnitPoseData.ActorPawn.Rotation.Yaw)), OnRotationYawClicked_Soldier,
											RotateSoldierSliderYaw);
	// Rotation Yaw
	GetListItem(Index++, bDisabled).UpdateDataSlider(m_Editor_Rotation_Roll,	string(abs(UnitPoseData.ActorPawn.Rotation.Roll * UnrRotToDeg)),	
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(UnitPoseData.ActorPawn.Rotation.Roll)),	OnRotationRollClicked_Soldier,
											RotateSoldierSliderRoll);

	// Scale X
	GetListItem(Index++, bDisabled).UpdateDataSlider(m_Editor_Scale_X,		string(UnitPoseData.ActorPawn.Mesh.Scale), 50, OnScaleSpinnerClicked_Soldier, ScaleSliderChanged_Soldier);
	
	// Reset Position
	// Reset Rotation
	// Reset Scale
	GetListItem(Index++, bDisabled).UpdateDataDescription(m_Editor_Position_Reset,		OnResetPosition);
	GetListItem(Index++, bDisabled).UpdateDataDescription(m_Editor_Rotation_Reset,		OnResetRotation);
	GetListItem(Index++, bDisabled).UpdateDataDescription(m_Editor_Scale_Reset,		OnResetScale);

	// Toggle Foot IK
	GetListItem(Index++, bDisabled).UpdateDataCheckbox(m_UnitEditor_HideUnit,			"",	UnitPoseData.ActorPawn.Mesh.HiddenGame, OnToggleHideUnit);

	// Toggle Left Hand IK
//	GetListItem(Index++).UpdateDataCheckbox(m_UnitEditor_ToggleLeftHandIK,	"", false, OnToggleFootIK);

//	GetListItem(Index++).UpdateDataCheckbox(m_UnitEditor_ToggleFootIK,		"",	CheckUnitFootIKState(UnitPoseData.ActorPawn), OnToggleFootIK);
}

function OnClickChangeSoldier()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_Soldier);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	TriggerScreenNeedsPopulate();
}

//
// Unselected List of Soldiers that's not already picked in the Photobooth
//
function PopulateSoldierList(out int Index)
{
	local array<string> SoldierNames;
	local int SoldierIndex, i;

	CurrentScreen.GetSoldierData(m_iLastTouchedSoldierIndex, SoldierNames, SoldierIndex);
	for (i = 0; i < SoldierNames.Length; i++)
	{
		GetListItem(Index++).UpdateDataDescription(SoldierNames[i], OnSetSoldier);
	}

	CurrentScreen.List.Scrollbar.SetPercent(0);
}

//
// Set Soldier/Unit functionality
//
function SetSoldier(int LocationIndex, int SoldierIndex)
{
	local array<StateObjectReference> arrSoldiers;
	local StateObjectReference Soldier;

	if (SoldierIndex < 0)
	{
		Soldier.ObjectID = 0;
	}
	else
	{
		`PHOTOBOOTH.GetPossibleSoldiers(LocationIndex, CurrentScreen.m_arrSoldiers, arrSoldiers);
		Soldier = arrSoldiers[SoldierIndex];
	}	

	`PHOTOBOOTH.SetSoldier(LocationIndex, Soldier, false, CurrentScreen.SoldierPawnCreated);

	// Fix for soldiers that appear beyond 6+ formations
	PhotoboothEx.EnqueueScale(LocationIndex, 1.0f);
	PhotoboothEx.EnqueueLocation(LocationIndex, `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].Location);
}

function OnSetSoldier()
{
	SetSoldier(m_iLastTouchedSoldierIndex, CurrentScreen.List.SelectedIndex - 1);

	// Return to soldier editor
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_SoldierEditor);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	TriggerScreenNeedsPopulate();
}

// Pose functionality
function OnChoosePose()
{
	SetScreenState(eUIPropagandaType_Pose);
	TriggerScreenNeedsPopulate();
}

function OnStepSpinnerChanged(UIListItemSpinner SpinnerControl, int Direction)
{
	Step += direction;

	//bsg-jedwards (5.4.17) : Use max spinner value instead of harcoded number
	if (Step < 0)
		Step = 10000.0f;
	else if (Step > 10000.0f)
		Step = 1.0f;
	//bsg-jedwards (5.4.17) : end	

	SpinnerControl.SetValue(string(Step));
}

// Allow players to click on the spinner to set a custom value
function OnStepSpinnerClicked()
{
	OpenTextBoxInputInterface( m_Editor_Step, string(Step), 5, 
																		PCTextField_OnAccept_NewValue_Step, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Step, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Step(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_Step(bWasSuccessful ? text : "");
}

function VirtualKeyboard_OnNewValueCancelled()
{
	PCTextField_OnCancel_AnyTextBox("");
}
// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_NewValue_Step(string userInput)
{
	Step = float(userInput);
	TriggerScreenNeedsPopulate();
}

function PCTextField_OnCancel_AnyTextBox(string userInput)
{
	//bsg-nlong (1.11.17): Reset the focus on the Navigators
	CurrentScreen.Navigator.SetSelected(CurrentScreen.ListContainer);
	CurrentScreen.ListContainer.Navigator.SetSelected(CurrentScreen.List);
	//bsg-nlong (1.11.17): end
}

function PositionSliderChanged_X_Soldier(UISlider SliderControl)
{
	local int Direction;

	if ( SliderControl.percent < SliderEditorPos_X_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_X_PrevPct )
		Direction = 1;

	PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].X += Direction * Step;
	PhotoboothEx.bCustomPositionSet	= true;
	//SliderControl.SetPercent(50);	// Reset back to center

	// Force an update
	UpdateSoldierPositionAndRotation();

	SliderControl.SetText(string(PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].X));

	SliderEditorPos_X_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionXSpinnerClicked_Soldier()
{
	OpenTextBoxInputInterface( m_Editor_Position_X, string(`PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Location.X), 10, 
																		PCTextField_OnAccept_NewValue_PosX_Soldier, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosX_Soldier, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosX_Soldier(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosX_Soldier(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosX_Soldier(string userInput)
{
	PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].X = float(userInput);

	// Force an update
	UpdateSoldierPositionAndRotation();

	TriggerScreenNeedsPopulate();
}

function PositionSliderChanged_Y_Soldier(UISlider SliderControl)
{
	local int Direction;

	if ( SliderControl.percent < SliderEditorPos_Y_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_Y_PrevPct )
		Direction = 1;

	PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].Y += Direction * Step;
	PhotoboothEx.bCustomPositionSet	= true;
	//SpinnerControl.SetPercent(50);	// Reset back to center

	// Force an update
	UpdateSoldierPositionAndRotation();

	SliderControl.SetText(string(PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].Y));

	SliderEditorPos_Y_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionYSpinnerClicked_Soldier()
{
	OpenTextBoxInputInterface( m_Editor_Position_Y, string(`PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Location.Y), 10, 
																		PCTextField_OnAccept_NewValue_PosY_Soldier, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosY_Soldier, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosY_Soldier(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosY_Soldier(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosY_Soldier(string userInput)
{
	PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].Y = float(userInput);

	// Force an update
	UpdateSoldierPositionAndRotation();

	TriggerScreenNeedsPopulate();
}

function PositionSliderChanged_Z_Soldier(UISlider SliderControl)
{
	local int Direction;

	if ( SliderControl.percent < SliderEditorPos_Z_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_Z_PrevPct )
		Direction = 1;

	PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].Z += Direction * Step;
	PhotoboothEx.bCustomPositionSet	= true;
	//SpinnerControl.SetPercent(50);	// Reset back to center

	// Force an update
	UpdateSoldierPositionAndRotation();

	SliderControl.SetText(string(PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].Z));

	SliderEditorPos_Z_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionZSpinnerClicked_Soldier()
{
	OpenTextBoxInputInterface( m_Editor_Position_Z, string(`PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Location.Z), 10, 
																		PCTextField_OnAccept_NewValue_PosZ_Soldier, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosZ_Soldier, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosZ_Soldier(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosZ_Soldier(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosZ_Soldier(string userInput)
{
	PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex].Z = float(userInput);

	// Force an update
	UpdateSoldierPositionAndRotation();

	TriggerScreenNeedsPopulate();
}
//
// Rotation Editor functionality
//
function RotateSoldierSliderPitch(UISlider SliderControl)
{
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex] = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Rotation;
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Pitch = SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	SliderControl.SetText(string(abs(`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Pitch * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function RotateSoldierSliderYaw(UISlider SliderControl)
{
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex] = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Rotation;
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Yaw = SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	SliderControl.SetText(string(abs(`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Yaw * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function RotateSoldierSliderRoll(UISlider SliderControl)
{
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex] = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Rotation;
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Roll = SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	SliderControl.SetText(string(abs(`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Roll * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}


function OnRotationPitchClicked_Soldier()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Pitch, string(abs(`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Pitch * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Pitch_Soldier, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Pitch_Soldier, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Pitch_Soldier(string text, bool bWasSuccessful)
{

	PCTextField_OnAccept_Rotation_Pitch_Soldier(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Pitch_Soldier(string userInput)
{
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex] = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Rotation;
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Pitch = class'X2Helpers_PhotoboothExtended'.static.DegreesToUNR(float(userInput));

	UpdateSoldierPositionAndRotation();

	TriggerScreenNeedsPopulate();
}

function OnRotationYawClicked_Soldier()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Yaw, string(abs(`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Yaw * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Yaw_Soldier, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Yaw_Soldier, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Yaw_Soldier(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Yaw_Soldier(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Yaw_Soldier(string userInput)
{
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex] = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Rotation;
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Yaw = class'X2Helpers_PhotoboothExtended'.static.DegreesToUNR(float(userInput));

	UpdateSoldierPositionAndRotation();

	TriggerScreenNeedsPopulate();
}

function OnRotationRollClicked_Soldier()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Roll, string(abs(`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Roll * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Roll_Soldier, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Roll_Soldier, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Roll_Soldier(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Roll_Soldier(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Roll_Soldier(string userInput)
{
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex] = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Rotation;
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex].Roll = class'X2Helpers_PhotoboothExtended'.static.DegreesToUNR(float(userInput));

	UpdateSoldierPositionAndRotation();

	TriggerScreenNeedsPopulate();
}

function ScaleSliderChanged_Soldier(UISlider SliderControl)
{
	local float ScalePercent;

	ScalePercent = SliderControl.Percent;

	if (ScalePercent > 100)
		ScalePercent = 100;
	else if (ScalePercent < 1)
		ScalePercent = 1;		// Game and Editor crashes if Scale is 0
	
	ScalePercent = (ScalePercent) / 50;

	`LOG("[" $ GetFuncName() $ "()] Slider Scale: " $ SliderControl.Percent $ "%, New Scale: " $ ScalePercent, true, default.class.name);

	PhotoboothEx.UpdateScale(m_iLastTouchedSoldierIndex, ScalePercent);

	// Force an update
	UpdateSoldierPositionAndRotation();

	SliderControl.SetText(string(PhotoboothEx.ActorScale[m_iLastTouchedSoldierIndex]));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnScaleSpinnerClicked_Soldier()
{
	OpenTextBoxInputInterface( m_Editor_Scale_X, string(PhotoboothEx.ActorScale[m_iLastTouchedSoldierIndex]), 10, 
																		PCTextField_OnAccept_NewValue_Scale_Soldier, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Scale_Soldier, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Scale_Soldier(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_Scale_Soldier(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_Scale_Soldier(string userInput)
{
	if (float(userInput) < 0.0f)
	{
		return;
	}

	PhotoboothEx.ActorScale[m_iLastTouchedSoldierIndex] = float(userInput);

	// Force an update
	UpdateSoldierPositionAndRotation();

	TriggerScreenNeedsPopulate();
}

function OnResetPosition()
{
	PhotoboothEx.ActorLocation[m_iLastTouchedSoldierIndex] = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].Location;

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetRotation()
{
	`PHOTOBOOTH.ActorRotation[m_iLastTouchedSoldierIndex] = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].Rotation;

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetScale()
{
	PhotoboothEx.ActorScale[m_iLastTouchedSoldierIndex] = 1.0f;

	// Force an update
	TriggerScreenNeedsPopulate();
}

/*
function OnToggleLeftHandIK(UICheckbox CheckboxControl)
{
	local XComUnitPawn Pawn;
	local name IKSocketName;
	local Name WeaponSocketName;
	local SkeletalMeshComponent PrimaryWeaponMeshComp;

	Pawn = `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn;

	IKSocketName = Pawn.GetLeftHandIKSocketName();
	WeaponSocketName = Pawn.GetLeftHandIKWeaponSocketName();

	foreach Pawn.Mesh.AttachedComponentsOnBone(class'SkeletalMeshComponent', PrimaryWeaponMeshComp, WeaponSocketName)
	{
		// Just do the first one
		break;
	}

	// Always force Left Hand IK strength to 0 first
	Pawn.LeftHandIK.ControlStrength = 0.0f;

	if( Pawn.LeftHandIK != None && PrimaryWeaponMeshComp != None)
	{
		if (CheckboxControl.bChecked)
			Pawn.LeftHandIK.ControlStrength = 1.0f;
	}
}
*/
function bool CheckUnitLeftHandIK(XComUnitPawn Pawn)
{
	if (Pawn.LeftHandIK.ControlStrength < 1.0f)
		return false;

	return true;
}

function OnToggleFootIK(UICheckbox CheckboxControl)
{
	`PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.EnableFootIK(CheckboxControl.bChecked);
}

function bool CheckUnitFootIKState(XComUnitPawn Pawn)
{
	local FootIKInfo IKInfo;

	foreach Pawn.FootIKInfos(IKInfo)
	{
		if (IKInfo.FootIKControl.ControlStrength < 1.0f)
			return false;
		break;	// Only the first one matters
	}

	return true;
}

function OnToggleHideUnit(UICheckbox CheckboxControl)
{
	local SkeletalMeshComponent MeshComp;

	// To do: Drop static mesh down to ground level.  Also - swap mesh on load for dead sectopods.
	`PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.Mesh.SetHidden(CheckboxControl.bChecked);
	// hide our gun
	foreach `PHOTOBOOTH.m_arrUnits[m_iLastTouchedSoldierIndex].ActorPawn.AllOwnedComponents(class'SkeletalMeshComponent', MeshComp)
	{
		MeshComp.SetHidden(CheckboxControl.bChecked);
	}
}

//
// Object List menu
//
function PopulateObjectsList(out int Index)
{
	local int i;

	for (i = 0; i < PhotoboothEx.arrProps.Length + 1; i++)
	{
		if (i >= PhotoboothEx.arrProps.Length)
		{
			GetListItem(Index++).UpdateDataValue(m_PrefixObject@i+1, m_CreateNewObject, OnObjectEditor);
		}
		else
		{
			GetListItem(Index++).UpdateDataValue(m_PrefixObject@i+1, string(PhotoboothEx.arrProps[i].TemplateInfo.TemplateName), OnObjectEditor);
		}
	}

	// Set new delegate for this set only
	// Remember to set this back after returning to any other part of the screen
	CurrentScreen.List.OnSelectionChanged = OnSelectedObjectListChange; //bsg-jneal (5.23.17): saving default list index for better nav
}

function OnSelectedObjectListChange(UIList ContainerList, int ItemIndex)
{
	iSelectedObjectDataIndex = CurrentScreen.List.SelectedIndex;
}

function OnObjectEditor()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_ObjectEditor);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	// Force an update
	TriggerScreenNeedsPopulate();
}

//
// Object Editing menu
//
function bool CreateNewProp(X2PhotoboothStaticMeshTemplate Template)
{
	local StaticMesh			NewMesh;
	local Vector				CurrentPos;
	local Rotator				CurrentRot;

	// Load in the object
	NewMesh = StaticMesh(DynamicLoadObject(Template.StaticMeshPath, class'StaticMesh', true));

	// If in Tactical, get the studio's current position
	CurrentPos = SetInitialObjectPosition();

	CurrentRot = Rotator(CurrentPos);
	CurrentRot.Pitch	= 0;  
	CurrentRot.Roll		= 0;

	// Get random point in space from current formation and place the object there
	PhotoboothEx.CreateNewProp(NewMesh, class'X2DownloadableContentInfo_Misc_PhotoboothExtended'.default.arrPhotoboothStaticMeshes[0],
	CurrentPos, 
	CurrentRot, 1.0f);

	return true;
}

function PopulateObjectEditorList(out int Index)
{
	// If we're here for the first time, create an object with default settings.
	local Actor_PhotoboothProp	ObjectPoseData;

	if (iSelectedObjectDataIndex >= PhotoboothEx.arrProps.Length)
	{
		CreateNewProp(class'X2DownloadableContentInfo_Misc_PhotoboothExtended'.default.arrPhotoboothStaticMeshes[0]);
	}

	ObjectPoseData	= PhotoboothEx.arrProps[iSelectedObjectDataIndex];

	// Select Object
	GetListItem(Index++).UpdateDataValue(m_ObjectEditor_SelectedObject,	string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].TemplateInfo.TemplateName), OnClickChangeObject);

	// Step
	GetListItem(Index++).UpdateDataSpinner(m_Editor_Step, string(Step),	OnStepSpinnerChanged, OnStepSpinnerClicked);

	// Position X
	// Position Y
	// Position Z
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_X, string(ObjectPoseData.ObjLocation.X), 50,	OnPositionXSpinnerClicked_Object, PositionSliderChanged_X_Object);
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_Y, string(ObjectPoseData.ObjLocation.Y), 50,	OnPositionYSpinnerClicked_Object, PositionSliderChanged_Y_Object);
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_Z, string(ObjectPoseData.ObjLocation.Z), 50,	OnPositionZSpinnerClicked_Object, PositionSliderChanged_Z_Object);

	// Rotation Pitch
	GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Pitch,	string(abs(ObjectPoseData.ObjRotation.Pitch * UnrRotToDeg)),
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(ObjectPoseData.ObjRotation.Pitch)),	OnRotationPitchClicked_Object,
											RotateSliderPitch_Object);
	// Rotation Roll
	GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Yaw,	string(abs(ObjectPoseData.ObjRotation.Yaw * UnrRotToDeg)),	
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(ObjectPoseData.ObjRotation.Yaw)),	OnRotationYawClicked_Object,
											RotateSliderYaw_Object);
	// Rotation Yaw
	GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Roll,	string(abs(ObjectPoseData.ObjRotation.Roll * UnrRotToDeg)),	
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(ObjectPoseData.ObjRotation.Roll)),	OnRotationRollClicked_Object,
											RotateSliderRoll_Object);

	// Scale X
	GetListItem(Index++).UpdateDataSlider(m_Editor_Scale_X,		string(ObjectPoseData.ObjScale), 50, OnScaleSpinnerClicked_Object, ScaleSliderChanged_Object);

	// Reset Position
	// Reset Rotation
	// Reset Scale
	GetListItem(Index++).UpdateDataDescription(m_Editor_Position_Reset,		OnResetPosition_Object);
	GetListItem(Index++).UpdateDataDescription(m_Editor_Rotation_Reset,		OnResetRotation_Object);
	GetListItem(Index++).UpdateDataDescription(m_Editor_Scale_Reset,		OnResetScale_Object);

	// Toggle Foot IK
	GetListItem(Index++).UpdateDataCheckbox(m_ObjectEditor_HideObject,			"",	ObjectPoseData.bIsHidden, OnToggleHideObject);

	GetListItem(Index).DisableNavigation(); //bsg-jneal (5.16.17): don't allow navigation on hidden list items
	GetListItem(Index++).Hide();

	GetListItem(Index++).UpdateDataDescription(m_ObjectEditor_DeleteObject,		OnDeleteObjectClicked).SetBad(true, "");
}

function OnClickChangeObject()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_PickObjectData);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	// Force an update
	TriggerScreenNeedsPopulate();
}

//
// Set Object functionality
//
function PopulatePickObjectList(out int Index)
{
	local X2PhotoboothStaticMeshTemplate iterTemplate;

	foreach class'X2DownloadableContentInfo_Misc_PhotoboothExtended'.default.arrPhotoboothStaticMeshes(iterTemplate)
	{
		GetListItem(Index++).UpdateDataDescription(string(iterTemplate.TemplateName), OnSetObject);
	}

	CurrentScreen.List.Scrollbar.SetPercent(0);
}

function OnSetObject()
{
	// Load in the object
	PhotoboothEx.UpdatePropInfo(iSelectedObjectDataIndex, class'X2DownloadableContentInfo_Misc_PhotoboothExtended'.default.arrPhotoboothStaticMeshes[CurrentScreen.List.SelectedIndex]);

	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_ObjectEditor);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	// Force an update
	TriggerScreenNeedsPopulate();
}

//
// Object Editor functionality
//
function PositionSliderChanged_X_Object(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_X_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_X_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation;
	newPos.X += Direction * Step;

	PhotoboothEx.UpdatePropLocation(iSelectedObjectDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation.X));

	SliderEditorPos_X_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionXSpinnerClicked_Object()
{
	OpenTextBoxInputInterface( m_Editor_Position_X, string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation.X), 10, 
																		PCTextField_OnAccept_NewValue_PosX_Object, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosX_Object, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosX_Object(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosX_Object(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosX_Object(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation;
	newPos.X = float(userInput);

	PhotoboothEx.UpdatePropLocation(iSelectedObjectDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

function PositionSliderChanged_Y_Object(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_Y_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_Y_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation;
	newPos.Y += Direction * Step;

	PhotoboothEx.UpdatePropLocation(iSelectedObjectDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation.Y));

	SliderEditorPos_Y_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionYSpinnerClicked_Object()
{
	OpenTextBoxInputInterface( m_Editor_Position_Y, string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation.Y), 10, 
																		PCTextField_OnAccept_NewValue_PosY_Object, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosY_Object, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosY_Object(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosY_Object(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosY_Object(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation;
	newPos.Y = float(userInput);

	PhotoboothEx.UpdatePropLocation(iSelectedObjectDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

function PositionSliderChanged_Z_Object(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_Z_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_Z_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation;
	newPos.Z += Direction * Step;

	PhotoboothEx.UpdatePropLocation(iSelectedObjectDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation.Z));

	SliderEditorPos_Z_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionZSpinnerClicked_Object()
{
	OpenTextBoxInputInterface( m_Editor_Position_Z, string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation.Z), 10, 
																		PCTextField_OnAccept_NewValue_PosZ_Object, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosZ_Object, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosZ_Object(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosZ_Object(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosZ_Object(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjLocation;
	newPos.Z = float(userInput);

	PhotoboothEx.UpdatePropLocation(iSelectedObjectDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

//
// Rotation Editor functionality
//
function RotateSliderPitch_Object(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation;
	NewRot.Pitch	= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdatePropRotation(iSelectedObjectDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Pitch * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function RotateSliderYaw_Object(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation;
	NewRot.Yaw		= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdatePropRotation(iSelectedObjectDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Yaw * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function RotateSliderRoll_Object(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation;
	NewRot.Roll		= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdatePropRotation(iSelectedObjectDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Roll * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}


function OnRotationPitchClicked_Object()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Pitch, string(abs(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation.Pitch * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Pitch_Object, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Pitch_Object, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Pitch_Object(string text, bool bWasSuccessful)
{

	PCTextField_OnAccept_Rotation_Pitch_Object(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Pitch_Object(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation;
	NewRot.Roll		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdatePropRotation(iSelectedObjectDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function OnRotationYawClicked_Object()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Yaw, string(abs(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation.Yaw * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Yaw_Object, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Yaw_Object, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Yaw_Object(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Yaw_Object(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Yaw_Object(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation;
	NewRot.Yaw		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdatePropRotation(iSelectedObjectDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function OnRotationRollClicked_Object()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Roll, string(abs(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation.Roll * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Roll_Object, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Roll_Object, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Roll_Object(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Roll_Object(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Roll_Object(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation;
	NewRot.Roll		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdatePropRotation(iSelectedObjectDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function ScaleSliderChanged_Object(UISlider SliderControl)
{
	local float ScalePercent;

	ScalePercent = SliderControl.Percent;

	if (ScalePercent > 100)
		ScalePercent = 100;
	else if (ScalePercent < 1)
		ScalePercent = 1;		// Game and Editor crashes if Scale is 0
	
	ScalePercent = (ScalePercent) / 50;

	PhotoboothEx.UpdatePropScale(iSelectedObjectDataIndex, ScalePercent);

	SliderControl.SetText(string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjScale));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnScaleSpinnerClicked_Object()
{
	OpenTextBoxInputInterface( m_Editor_Scale_X, string(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjScale), 10, 
																		PCTextField_OnAccept_NewValue_Scale_Object, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Scale_Object, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Scale_Object(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_Scale_Object(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_Scale_Object(string userInput)
{
	if (float(userInput) > 0.0f)
	{
		return;
	}

	PhotoboothEx.UpdatePropScale(iSelectedObjectDataIndex, float(userInput));

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetPosition_Object()
{
	PhotoboothEx.UpdatePropLocation(iSelectedObjectDataIndex, SetInitialObjectPosition());

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetRotation_Object()
{
	local Rotator CurrentRot;

	CurrentRot = Rotator(SetInitialObjectPosition());
	CurrentRot.Pitch	= 0;  
	CurrentRot.Roll		= 0;

	PhotoboothEx.UpdatePropRotation(iSelectedObjectDataIndex, CurrentRot);

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetScale_Object()
{
	PhotoboothEx.UpdatePropScale(iSelectedObjectDataIndex, 1.0f);

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnToggleHideObject(UICheckbox CheckboxControl)
{
	PhotoboothEx.UpdatePropVisibility(iSelectedObjectDataIndex, CheckboxControl.bChecked);
}

function OnDeleteObjectClicked()
{
	PhotoboothEx.RemoveProp(iSelectedObjectDataIndex);

	iSelectedObjectDataIndex = 0;

	OnObjects();
}

//
// Lights menu
//
function PopulateLightsList(out int Index)
{
	local int i;

	for (i = 0; i < PhotoboothEx.arrLightEmitters.Length + 1; i++)
	{
		if (i >= PhotoboothEx.arrLightEmitters.Length)
		{
			GetListItem(Index++).UpdateDataDescription(m_CreateNewLight, OnLightEditor);
		}
		else
		{
			GetListItem(Index++).UpdateDataDescription(m_PrefixLight@i+1, OnLightEditor);
		}
	}

	// Set new delegate for this set only
	// Remember to set this back after returning to any other part of the screen
	CurrentScreen.List.OnSelectionChanged = OnSelectedLightListChange; //bsg-jneal (5.23.17): saving default list index for better nav
}

function OnSelectedLightListChange(UIList ContainerList, int ItemIndex)
{
	iSelectedLightDataIndex = CurrentScreen.List.SelectedIndex; // So other subsystems know we're focused on a soldier
}

function OnLightEditor()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_LightEditor);
	CurrentScreen.List.ItemContainer.RemoveChildren();
	TriggerScreenNeedsPopulate();
}

function bool CreateNewLight()
{
	local Vector				CurrentPos;
	local Rotator				CurrentRot;

	// If in Tactical, get the studio's current position
	CurrentPos = SetInitialObjectPosition();
	CurrentPos.Z += 12;

	CurrentRot = Rotator(CurrentPos);
	CurrentRot.Pitch	= 0;  
	CurrentRot.Roll		= 0;

	// Create a new light
	PhotoboothEx.CreateNewLight(CurrentPos, CurrentRot, "FFFFFF", 10.0f);

	return true;
}

function PopulateLightEditorList(out int Index)
{
	// If we're here for the first time, create an object with default settings.
	local Actor_PhotoboothLight	LightPoseData;

	if (iSelectedLightDataIndex >= PhotoboothEx.arrLightEmitters.Length)
	{
		CreateNewLight();
	}

	LightPoseData	= PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex];

	PhotoboothEx.UpdateLightMeshHelperVisibility(iSelectedLightDataIndex, false);

	// Select Object
	//GetListItem(Index++).UpdateDataValue(m_LightEditor_SelectedObject,	string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].TemplateInfo.TemplateName), OnClickChangeObject);
	GetListItem(Index++).UpdateDataSpinner(m_LightEditor_Type, LightPoseData.GetLightDescription(), OnChangeLightType);

	// Brightness
	GetListItem(Index++).UpdateDataSlider(m_LightEditor_Brightness,	string(LightPoseData.ObjBrightness), int(LightPoseData.ObjBrightness * 5),	, MoveSliderBrightness);

	// Hex Color
	GetListItem(Index++).UpdateDataColorChip(m_LightEditor_HexColor, LightPoseData.objColorHexStr, OnHexColorClicked_Light);

	if (LightPoseData.eActiveLightType == ePBLight_Spot)
	{
		// Cone Inner Radius
		GetListItem(Index++).UpdateDataSlider(m_LightEditor_Spot_InnerConeAngle, string(LightPoseData.SpotLight.InnerConeAngle), LightPoseData.SpotLight.InnerConeAngle, , MoveSliderSpotLight_InnerCone);
		// Cone Outer Radius
		GetListItem(Index++).UpdateDataSlider(m_LightEditor_Spot_OuterConeAngle, string(LightPoseData.SpotLight.OuterConeAngle), LightPoseData.SpotLight.OuterConeAngle, , MoveSliderSpotLight_OuterCone);
	}

	// Step
	GetListItem(Index++).UpdateDataSpinner(m_Editor_Step, string(Step),	OnStepSpinnerChanged, OnStepSpinnerClicked);

	// Position X
	// Position Y
	// Position Z
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_X, string(LightPoseData.ObjLocation.X), 50,	OnPositionXSpinnerClicked_Light, PositionSliderChanged_X_Light);
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_Y, string(LightPoseData.ObjLocation.Y), 50,	OnPositionYSpinnerClicked_Light, PositionSliderChanged_Y_Light);
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_Z, string(LightPoseData.ObjLocation.Z), 50,	OnPositionZSpinnerClicked_Light, PositionSliderChanged_Z_Light);

	// Rotation Pitch
	if (LightPoseData.eActiveLightType == ePBLight_Spot)
	{
		GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Pitch,	string(abs(LightPoseData.ObjRotation.Pitch * UnrRotToDeg)),
												class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(LightPoseData.ObjRotation.Pitch)),	OnRotationPitchClicked_Light,
												RotateSliderPitch_Light);
		// Rotation Roll
		GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Yaw,	string(abs(LightPoseData.ObjRotation.Yaw * UnrRotToDeg)),	
												class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(LightPoseData.ObjRotation.Yaw)),	OnRotationYawClicked_Light,
												RotateSliderYaw_Light);
		// Rotation Yaw
		GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Roll,	string(abs(LightPoseData.ObjRotation.Roll * UnrRotToDeg)),	
												class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(LightPoseData.ObjRotation.Roll)),	OnRotationRollClicked_Light,
												RotateSliderRoll_Light);
	}

	// Reset Position
	// Reset Rotation
	// Reset Scale
	GetListItem(Index++).UpdateDataDescription(m_Editor_Position_Reset,		OnResetPosition_Light);

	if (LightPoseData.eActiveLightType == ePBLight_Spot)
	{
		GetListItem(Index++).UpdateDataDescription(m_Editor_Rotation_Reset,		OnResetRotation_Light);
	}

	// Toggle Light
	GetListItem(Index++).UpdateDataCheckbox(m_LightEditor_HideLight,			"",	LightPoseData.bIsEnabled, OnToggleHide_Light);

	GetListItem(Index).DisableNavigation(); //bsg-jneal (5.16.17): don't allow navigation on hidden list items
	GetListItem(Index++).Hide();

	GetListItem(Index++).UpdateDataDescription(m_LightEditor_DeleteLight,		OnDeleteClicked_Light).SetBad(true, "");
}

/*
function EventListenerReturn OnExitLightEditorListener(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	PhotoboothEx.UpdateLightMeshHelperVisibility(iSelectedLightDataIndex, true);

	return ELR_NoInterrupt;
}
*/

function OnChangeLightType(UIListItemSpinner SpinnerControl, int Direction)
{
	if (Direction == -1)
	{
		PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].PreviousLight();
	}
	else if (Direction == 1)
	{
		PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].NextLight();
	}
	
	SpinnerControl.SetValue(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].GetLightDescription());

	TriggerScreenNeedsPopulate();
}

//
// Light Editor functionality
//
function MoveSliderBrightness(UISlider SliderControl)
{
	local float CalculatedBrightness;

	CalculatedBrightness = SliderControl.percent * 0.20f;

	PhotoboothEx.UpdateLightBrightness(iSelectedLightDataIndex, CalculatedBrightness);

	`LOG("[" $ GetFuncName() $ "()] New Brightness: " $ PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjBrightness, true, default.class.name);

	SliderControl.SetText(string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjBrightness));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnHexColorClicked_Light()
{
	OpenTextBoxInputInterface( m_LightEditor_HexColor, PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].objColorHexStr, 6, 
																		PCTextField_OnAccept_Color_Light, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Color_Light, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Color_Light(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Color_Light(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Color_Light(string userInput)
{
	PhotoboothEx.UpdateLightColor(iSelectedLightDataIndex, userInput);

	TriggerScreenNeedsPopulate();
}

function MoveSliderSpotLight_InnerCone(UISlider SliderControl)
{
	PhotoboothEx.UpdateSpotLightParams(iSelectedLightDataIndex, SliderControl.percent);

	SliderControl.SetText(string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].SpotLight.InnerConeAngle));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function MoveSliderSpotLight_OuterCone(UISlider SliderControl)
{
	PhotoboothEx.UpdateSpotLightParams(iSelectedLightDataIndex, , SliderControl.percent);

	SliderControl.SetText(string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].SpotLight.OuterConeAngle));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

//
// Position Editor - Lights
//
function PositionSliderChanged_X_Light(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_X_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_X_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation;
	newPos.X += Direction * Step;

	PhotoboothEx.UpdateLightLocation(iSelectedLightDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation.X));

	SliderEditorPos_X_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionXSpinnerClicked_Light()
{
	OpenTextBoxInputInterface( m_Editor_Position_X, string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation.X), 10, 
																		PCTextField_OnAccept_NewValue_PosX_Light, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosX_Light, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosX_Light(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosX_Light(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosX_Light(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation;
	newPos.X = float(userInput);

	PhotoboothEx.UpdateLightLocation(iSelectedLightDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

function PositionSliderChanged_Y_Light(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_Y_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_Y_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation;
	newPos.Y += Direction * Step;

	PhotoboothEx.UpdateLightLocation(iSelectedLightDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation.Y));

	SliderEditorPos_Y_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionYSpinnerClicked_Light()
{
	OpenTextBoxInputInterface( m_Editor_Position_Y, string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation.Y), 10, 
																		PCTextField_OnAccept_NewValue_PosY_Light, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosY_Light, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosY_Light(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosY_Light(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosY_Light(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation;
	newPos.Y = float(userInput);

	PhotoboothEx.UpdateLightLocation(iSelectedLightDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

function PositionSliderChanged_Z_Light(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_Z_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_Z_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation;
	newPos.Z += Direction * Step;

	PhotoboothEx.UpdateLightLocation(iSelectedLightDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation.Z));

	SliderEditorPos_Z_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionZSpinnerClicked_Light()
{
	OpenTextBoxInputInterface( m_Editor_Position_Z, string(PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation.Z), 10, 
																		PCTextField_OnAccept_NewValue_PosZ_Light, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosZ_Light, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosZ_Light(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosZ_Light(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosZ_Light(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjLocation;
	newPos.Z = float(userInput);

	PhotoboothEx.UpdateLightLocation(iSelectedLightDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

//
// Rotation Editor - Lights
//
function RotateSliderPitch_Light(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjRotation;
	NewRot.Pitch	= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdateLightRotation(iSelectedLightDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Pitch * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function RotateSliderYaw_Light(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjRotation;
	NewRot.Yaw		= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdateLightRotation(iSelectedLightDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Yaw * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function RotateSliderRoll_Light(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjRotation;
	NewRot.Roll		= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdateLightRotation(iSelectedLightDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Roll * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}


function OnRotationPitchClicked_Light()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Pitch, string(abs(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation.Pitch * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Pitch_Light, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Pitch_Light, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Pitch_Light(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Pitch_Light(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Pitch_Light(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjRotation;
	NewRot.Roll		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdateLightRotation(iSelectedLightDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function OnRotationYawClicked_Light()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Yaw, string(abs(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation.Yaw * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Yaw_Light, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Yaw_Light, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Yaw_Light(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Yaw_Light(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Yaw_Light(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjRotation;
	NewRot.Yaw		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdateLightRotation(iSelectedLightDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function OnRotationRollClicked_Light()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Roll, string(abs(PhotoboothEx.arrProps[iSelectedObjectDataIndex].ObjRotation.Roll * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Roll_Light, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Roll_Light, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Roll_Light(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Roll_Light(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Roll_Light(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrLightEmitters[iSelectedLightDataIndex].ObjRotation;
	NewRot.Roll		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdateLightRotation(iSelectedLightDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function OnResetPosition_Light()
{
	PhotoboothEx.UpdateLightLocation(iSelectedLightDataIndex, SetInitialObjectPosition());

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetRotation_Light()
{
	local Rotator CurrentRot;

	CurrentRot = Rotator(SetInitialObjectPosition());
	CurrentRot.Pitch	= 0;  
	CurrentRot.Roll		= 0;

	PhotoboothEx.UpdateLightRotation(iSelectedLightDataIndex, CurrentRot);

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnToggleHide_Light(UICheckbox CheckboxControl)
{
	PhotoboothEx.UpdateLightVisibility(iSelectedLightDataIndex, CheckboxControl.bChecked);
}

function OnDeleteClicked_Light()
{
	PhotoboothEx.RemoveLight(iSelectedLightDataIndex);

	iSelectedLightDataIndex = 0;

	OnLightSources();	// Exit the editor menu
}

//
// Extended Options
//

function PopulateExtendedOptionsList(out int Index)
{
	GetListItem(Index++, !bMCO_Enabled, m_Tooltip_Disabled_MCO).UpdateDataValue(m_ExtOptions_PosterLandscapeSizeX,		string(class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeX), OnOptionValueClicked_PosterResolution_X);
	GetListItem(Index++, !bMCO_Enabled, m_Tooltip_Disabled_MCO).UpdateDataValue(m_ExtOptions_PosterLandscapeSizeY,		string(class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeY), OnOptionValueClicked_PosterResolution_Y);
}

function OnOptionValueClicked_PosterResolution_X()
{
	OpenTextBoxInputInterface( m_ExtOptions_PosterLandscapeSizeX, string(class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeX), 4, 
																		PCTextField_OnAccept_NewValue_Option_PosterResolutionX, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Option_PosterResolutionX, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Option_PosterResolutionX(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_Option_PosterResolutionX(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_NewValue_Option_PosterResolutionX(string userInput)
{
	class'PhotoboothExtendedSettings'.static.SetInt_PosterSizeLandscape_X(int(userInput));

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnOptionValueClicked_PosterResolution_Y()
{
	OpenTextBoxInputInterface( m_ExtOptions_PosterLandscapeSizeY, string(class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeY), 4, 
																		PCTextField_OnAccept_NewValue_Option_PosterResolutionY, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Option_PosterResolutionY, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Option_PosterResolutionY(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_Option_PosterResolutionY(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_NewValue_Option_PosterResolutionY(string userInput)
{
	class'PhotoboothExtendedSettings'.static.SetInt_PosterSizeLandscape_Y(int(userInput));

	// Force an update
	TriggerScreenNeedsPopulate();
}

//
// Text/Graphics List
// 5/18/23: New menu items for Text modifications
//
function PopulateGraphicsList(out int Index)
{
	local array<string> FontNames;
	local int i;
	local delegate<UIPhotoboothBase.OnClickDelegate> OnChooseTextColorDel, OnChooseTextFontDel, OnRandomizePressDel;

	GetFontDataSpecific(FontNames, `PHOTOBOOTH.m_PosterFont);

	GetListItem(Index++).UpdateDataValue(m_Graphics_TextRandomize_Button, "", OnPressRandomizeTextBoxAll);
	GetListItem(Index++).UpdateDataCheckbox(m_Graphics_TextRandomize_IgnoreFormations,	"",	bRandomizeTextIgnoreFormations,	OnToggleCheckbox_RandomizeTextIgnoreFormation);

	GetListItem(Index).DisableNavigation(); // Hidden Item
	GetListItem(Index++).Hide();

	for (i = 0; i < `PHOTOBOOTH.m_currentTextLayoutTemplate.NumTextBoxes; i++)
	{
		switch (i)
		{
		case 0:
			OnChooseTextColorDel	= CurrentScreen.OnChooseTextBoxColor0;
			OnChooseTextFontDel		= CurrentScreen.OnChooseTextBoxFont0;
		//	OnRandomizePressDel		= OnPressRandomizeTextBox0;
			break;
		case 1:
			OnChooseTextColorDel	= CurrentScreen.OnChooseTextBoxColor1;
			OnChooseTextFontDel		= CurrentScreen.OnChooseTextBoxFont1;
		//	OnRandomizePressDel		= OnPressRandomizeTextBox1;
			break;
		case 2:
			OnChooseTextColorDel	= CurrentScreen.OnChooseTextBoxColor2;
			OnChooseTextFontDel		= CurrentScreen.OnChooseTextBoxFont2;
		//	OnRandomizePressDel		= OnPressRandomizeTextBox2;
			break;
		case 3:
			OnChooseTextColorDel	= CurrentScreen.OnChooseTextBoxColor3;
			OnChooseTextFontDel		= CurrentScreen.OnChooseTextBoxFont3;
		//	OnRandomizePressDel		= OnPressRandomizeTextBox3;
			break;
		}
		//GetListItem(Index++).UpdateDataDescription(m_PrefixTextBox @ i + 1 @ `PHOTOBOOTH.m_PosterStrings[i], UpdateTextBox);
		
		// Switch to value for better readability
		GetListItem(Index++).UpdateDataValue(class'UIPhotoboothBase'.default.m_PrefixTextBox @ i + 1, `PHOTOBOOTH.m_PosterStrings[i], OpenPosterTextBoxInputInterface);
		GetListItem(Index++).UpdateDataColorChip(class'UIPhotoboothBase'.default.m_PrefixTextBoxColor @ i + 1 , `PHOTOBOOTH.m_FontColors[`PHOTOBOOTH.m_PosterStringColors[i]], OnChooseTextColorDel);
		GetListItem(Index++).UpdateDataValue(class'UIPhotoboothBase'.default.m_PrefixTextBoxFont @ i + 1, FontNames[i],				OnChooseTextFontDel);
	//	GetListItem(Index++).UpdateDataValue(m_Graphics_PrefixTextRandomize_Button @ i + 1,	"",		OnRandomizePressDel);

		GetListItem(Index).DisableNavigation(); // Hidden Item
		GetListItem(Index++).Hide();
		//GetListItem(Index++).UpdateDataSlider(m_PrefixTextBoxFont @ i + 1, m_PrefixTextBoxFont @ i + 1, `PHOTOBOOTH.m_FontSize[i], , UpdateTextSize);
	}
}

function OpenPosterTextBoxInputInterface()
{
	m_iCurrentModifyingTextBox = (CurrentScreen.List.SelectedIndex - 3) / 4;

	OpenTextBoxInputInterface(	class'UIPhotoboothBase'.default.m_PrefixTextBox @ m_iCurrentModifyingTextBox + 1, 
								`PHOTOBOOTH.GetTextBoxString(m_iCurrentModifyingTextBox), 
								`PHOTOBOOTH.GetMaxStringLength(m_iCurrentModifyingTextBox), 
								PCTextField_OnAccept_TextBox, 
								PCTextField_OnCancel_AnyTextBox,
								VirtualKeyboard_OnBackgroundInputBoxAccepted, 
								VirtualKeyboard_OnBackgroundInputBoxCancelled);

}

function VirtualKeyboard_OnBackgroundInputBoxAccepted(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_TextBox(bWasSuccessful ? text : "");
}

function VirtualKeyboard_OnBackgroundInputBoxCancelled()
{
	PCTextField_OnCancel_AnyTextBox("");
}

function PCTextField_OnAccept_TextBox(string userInput)
{
	`PHOTOBOOTH.m_bChangedDefaultPosterStrings[m_iCurrentModifyingTextBox] = true;
	`PHOTOBOOTH.SetTextBoxString(m_iCurrentModifyingTextBox, userInput);
	TriggerScreenNeedsPopulate();
}

function OnPressRandomizeTextBoxBase()
{
	local Photobooth_AutoTextUsage autoText;
	local int Value;
	local array<string> PosterStrings, PosterFont;
	local array<int>	PosterStringColor;

	// Pull the text out from X2Photobooth
	PosterStrings		= `PHOTOBOOTH.m_PosterStrings;
	PosterFont			= `PHOTOBOOTH.m_PosterFont;
	PosterStringColor	= `PHOTOBOOTH.m_PosterStringColors;
	
	// If ignore formations is on, randomly pick between the three avaliable autotext
	if (bRandomizeTextIgnoreFormations)
		Value = `SYNC_RAND(3);
	else
		Value = `PHOTOBOOTH.GetTotalActivePawns();

	switch (Value)
	{
	case 1:
		autoText = ePBAT_SOLO;
		break;
	case 2:
		autoText = ePBAT_DUO;
		break;
	default:
		autoText = ePBAT_SQUAD;
		break;
	}

	class'X2Helpers_PhotoboothExtended'.static.GenerateExpandedAutoTextStrings(autoText, ePBTLS_Auto);

	// If our index isn't -1, then extract the string
	if (m_iLastTouchedTextBox > -1)
	{
		`PHOTOBOOTH.SetTextBoxString(m_iLastTouchedTextBox, PosterStrings[m_iLastTouchedTextBox]);
		`PHOTOBOOTH.SetTextBoxFont(m_iLastTouchedTextBox,	PosterFont[m_iLastTouchedTextBox]);
		`PHOTOBOOTH.SetTextBoxColor(m_iLastTouchedTextBox,	PosterStringColor[m_iLastTouchedTextBox]);
	}

	TriggerScreenNeedsPopulate();
}

function OnPressRandomizeTextBoxAll()
{
	m_iLastTouchedTextBox = -1;
	OnPressRandomizeTextBoxBase();
}

function OnPressRandomizeTextBox0()
{
	m_iLastTouchedTextBox = 0;
	OnPressRandomizeTextBoxBase();
}
function OnPressRandomizeTextBox1()
{
	m_iLastTouchedTextBox = 1;
	OnPressRandomizeTextBoxBase();
}

function OnPressRandomizeTextBox2()
{
	m_iLastTouchedTextBox = 2;
	OnPressRandomizeTextBoxBase();
}

function OnPressRandomizeTextBox3()
{
	m_iLastTouchedTextBox = 3;
	OnPressRandomizeTextBoxBase();
}

function OnToggleCheckbox_RandomizeTextIgnoreFormation(UICheckbox CheckboxControl)
{
	bRandomizeTextIgnoreFormations = CheckboxControl.bChecked;
}

function GetFontDataSpecific(out array<string> FontNames, array<String> FontParameters)
{
	local array<FontOptions> arrFonts;
	local int i, j;

	`PHOTOBOOTH.GetFonts(arrFonts);

	FontNames.length = 0;
	for (j = 0; j < FontParameters.length; j++)
	{
		for (i = 0; i < arrFonts.length; ++i)
		{
			if (arrFonts[i].FontName == FontParameters[j])
			{
				FontNames.AddItem(arrFonts[i].FontDisplayName);
			}
		}
	}
}
//
// Landscape Mode
//

function PopulateLandscapeModeMenu(out int Index)
{
	CurrentScreen.List.Hide();
	CurrentScreen.ListBG.Hide();
	CurrentScreen.ListContainer.Hide();
	CurrentScreen.CameraOutline.Hide();
	CurrentScreen.PosterOutline.Hide();
	CurrentScreen.TitleHeader.Hide();

	CurrentScreen.m_CameraPanel.Hide();
	CurrentScreen.m_PresetFullBody.Hide();
	CurrentScreen.m_PresetHeadshot.Hide();
	CurrentScreen.m_PresetHigh.Hide();
	CurrentScreen.m_PresetLow.Hide();
	CurrentScreen.m_PresetProfile.Hide();
	CurrentScreen.m_PresetTight.Hide();

	UIPhotoboothMovie_PE(CurrentScreen.Movie.Pres.GetPhotoboothMovie()).ChangeResolution(class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeX, class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeY, true);
//	`PHOTOBOOTH.UpdatePosterTexture();
	CurrentScreen.Movie.Pres.GetPhotoboothMovie().Hide();

	//BG.Hide();
}

function OnExitLandscapeMode()
{
	class'PhotoboothExtendedSettings'.static.SetBool_System_IsInLandscapeMode(false);

	CurrentScreen.List.Show();
	CurrentScreen.ListBG.Show();
	CurrentScreen.ListContainer.Show();
	CurrentScreen.CameraOutline.Show();
	CurrentScreen.PosterOutline.Show();
	CurrentScreen.TitleHeader.Show();

	CurrentScreen.m_CameraPanel.Show();
	CurrentScreen.m_PresetFullBody.Show();
	CurrentScreen.m_PresetHeadshot.Show();
	CurrentScreen.m_PresetHigh.Show();
	CurrentScreen.m_PresetLow.Show();
	CurrentScreen.m_PresetProfile.Show();
	CurrentScreen.m_PresetTight.Show();

	//BG.Show();

	UIPhotoboothMovie_PE(CurrentScreen.Movie.Pres.GetPhotoboothMovie()).ResetResolution();
//	`PHOTOBOOTH.UpdatePosterTexture();

	CurrentScreen.Movie.Pres.GetPhotoboothMovie().Show();
}

function UpdateSoldierPositionAndRotation()
{
	local int i;

	for (i = 0; i < `PHOTOBOOTH.m_arrUnits.Length; i++)
	{
		if (`PHOTOBOOTH.m_arrUnits[i].ActorPawn != none)
		{
			`PHOTOBOOTH.m_arrUnits[i].ActorPawn.SetRotation(`PHOTOBOOTH.ActorRotation[i]);
			
			// Sets Location Vector on the pawn
			if (PhotoboothEx.bCustomPositionSet) 
				`PHOTOBOOTH.m_arrUnits[i].ActorPawn.SetLocationNoCollisionCheck(PhotoboothEx.ActorLocation[i]);

			// Sets Scale on the Pawn
			`PHOTOBOOTH.m_arrUnits[i].ActorPawn.Mesh.SetScale(PhotoboothEx.ActorScale[i]);
		}
	}
}

//
// Effect List menu
//
/* TODO: Fix errors on Particle Effect making
function PopulateEffectsList(out int Index)
{
	local int i;

	for (i = 0; i < PhotoboothEx.arrProps.Length + 1; i++)
	{
		if (i >= PhotoboothEx.arrProps.Length)
		{
			GetListItem(Index++).UpdateDataValue(m_PrefixEffect@i+1, m_CreateNewEffect, OnEffectEditor);
		}
		else
		{
			GetListItem(Index++).UpdateDataValue(m_PrefixEffect@i+1, string(PhotoboothEx.arrProps[i].TemplateInfo.TemplateName), OnEffectEditor);
		}
	}

	// Set new delegate for this set only
	// Remember to set this back after returning to any other part of the screen
	CurrentScreen.List.OnSelectionChanged = OnSelectedEffectListChange; //bsg-jneal (5.23.17): saving default list index for better nav
}

function OnSelectedEffectListChange(UIList ContainerList, int ItemIndex)
{
	iSelectedEffectDataIndex = CurrentScreen.List.SelectedIndex;
}

function OnEffectEditor()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_EffectEditor);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	// Force an update
	TriggerScreenNeedsPopulate();
}

//
// Effect Editing menu
//
function bool CreateNewEffect(X2PhotoboothFXTemplate Template)
{
	local StaticMesh			NewMesh;
	local Vector				CurrentPos;
	local Rotator				CurrentRot;

	// Get a vector from the screen's delegate
	CurrentPos = SetInitialEffectPosition();

	CurrentRot = Rotator(CurrentPos);
	CurrentRot.Pitch	= 0;  
	CurrentRot.Roll		= 0;

	// Get random point in space from current formation and place the Effect there
	PhotoboothEx.CreateNewEffects(class'X2DownloadableContentInfo_Misc_PhotoboothExtended'.default.arrPhotoboothStaticMeshes[0],
	CurrentPos, 
	CurrentRot, 1.0f);

	return true;
}

function PopulateEffectEditorList(out int Index)
{
	// If we're here for the first time, create an Effect with default settings.
	local Actor_PhotoboothProp	EffectPoseData;

	if (iSelectedEffectDataIndex >= PhotoboothEx.arrProps.Length)
	{
		CreateNewEffect(class'X2DownloadableContentInfo_Misc_PhotoboothExtended'.default.arrPhotoboothStaticMeshes[0]);
	}

	EffectPoseData	= PhotoboothEx.arrProps[iSelectedEffectDataIndex];

	// Select Effect
	GetListItem(Index++).UpdateDataValue(m_EffectEditor_SelectedEffect,	string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].TemplateInfo.TemplateName), OnClickChangeEffect);

	// Step
	GetListItem(Index++).UpdateDataSpinner(m_Editor_Step, string(Step),	OnStepSpinnerChanged, OnStepSpinnerClicked);

	// Position X
	// Position Y
	// Position Z
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_X, string(EffectPoseData.ObjLocation.X), 50,	OnPositionXSpinnerClicked_Effect, PositionSliderChanged_X_Effect);
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_Y, string(EffectPoseData.ObjLocation.Y), 50,	OnPositionYSpinnerClicked_Effect, PositionSliderChanged_Y_Effect);
	UIMechaListItem_PhotoboothEx(GetListItem(Index++)).UpdateDataSliderPosition(m_Editor_Position_Z, string(EffectPoseData.ObjLocation.Z), 50,	OnPositionZSpinnerClicked_Effect, PositionSliderChanged_Z_Effect);

	// Rotation Pitch
	GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Pitch,	string(abs(EffectPoseData.ObjRotation.Pitch * UnrRotToDeg)),
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(EffectPoseData.ObjRotation.Pitch)),	OnRotationPitchClicked_Effect,
											RotateSliderPitch_Effect);
	// Rotation Roll
	GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Yaw,	string(abs(EffectPoseData.ObjRotation.Yaw * UnrRotToDeg)),	
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(EffectPoseData.ObjRotation.Yaw)),	OnRotationYawClicked_Effect,
											RotateSliderYaw_Effect);
	// Rotation Yaw
	GetListItem(Index++).UpdateDataSlider(m_Editor_Rotation_Roll,	string(abs(EffectPoseData.ObjRotation.Roll * UnrRotToDeg)),	
											class'X2Helpers_PhotoboothExtended'.static.UNRRotationPercent(float(EffectPoseData.ObjRotation.Roll)),	OnRotationRollClicked_Effect,
											RotateSliderRoll_Effect);

	// Scale X
	GetListItem(Index++).UpdateDataSlider(m_Editor_Scale_X,		string(EffectPoseData.ObjScale), 50, OnScaleSpinnerClicked_Effect, ScaleSliderChanged_Effect);

	// Reset Position
	// Reset Rotation
	// Reset Scale
	GetListItem(Index++).UpdateDataDescription(m_Editor_Position_Reset,		OnResetPosition_Effect);
	GetListItem(Index++).UpdateDataDescription(m_Editor_Rotation_Reset,		OnResetRotation_Effect);
	GetListItem(Index++).UpdateDataDescription(m_Editor_Scale_Reset,		OnResetScale_Effect);

	// Toggle Foot IK
	GetListItem(Index++).UpdateDataCheckbox(m_EffectEditor_HideEffect,			"",	EffectPoseData.bIsHidden, OnToggleHideEffect);

	GetListItem(Index).DisableNavigation(); //bsg-jneal (5.16.17): don't allow navigation on hidden list items
	GetListItem(Index++).Hide();

	GetListItem(Index++).UpdateDataDescription(m_EffectEditor_DeleteEffect,		OnDeleteEffectClicked).SetBad(true, "");
}

function OnClickChangeEffect()
{
	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_PickEffectData);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	// Force an update
	TriggerScreenNeedsPopulate();
}

//
// Set Effect functionality
//
function PopulatePickEffectList(out int Index)
{
	local X2PhotoboothStaticMeshTemplate iterTemplate;

	foreach class'X2DownloadableContentInfo_Misc_PhotoboothExtended'.default.arrPhotoboothStaticMeshes(iterTemplate)
	{
		GetListItem(Index++).UpdateDataDescription(string(iterTemplate.TemplateName), OnSetEffect);
	}

	CurrentScreen.List.Scrollbar.SetPercent(0);
}

function OnSetEffect()
{
	// Load in the Effect
	PhotoboothEx.UpdatePropInfo(iSelectedEffectDataIndex, class'X2DownloadableContentInfo_Misc_PhotoboothExtended'.default.arrPhotoboothStaticMeshes[CurrentScreen.List.SelectedIndex]);

	CurrentScreen.List.OnSelectionChanged = none;
	SetScreenState(eUIPropagandaType_EffectEditor);
	CurrentScreen.List.ItemContainer.RemoveChildren();

	// Force an update
	TriggerScreenNeedsPopulate();
}

//
// Effect Editor functionality
//
function PositionSliderChanged_X_Effect(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_X_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_X_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation;
	newPos.X += Direction * Step;

	PhotoboothEx.UpdatePropLocation(iSelectedEffectDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation.X));

	SliderEditorPos_X_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionXSpinnerClicked_Effect()
{
	OpenTextBoxInputInterface( m_Editor_Position_X, string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation.X), 10, 
																		PCTextField_OnAccept_NewValue_PosX_Effect, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosX_Effect, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosX_Effect(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosX_Effect(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosX_Effect(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation;
	newPos.X = float(userInput);

	PhotoboothEx.UpdatePropLocation(iSelectedEffectDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

function PositionSliderChanged_Y_Effect(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_Y_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_Y_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation;
	newPos.Y += Direction * Step;

	PhotoboothEx.UpdatePropLocation(iSelectedEffectDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation.Y));

	SliderEditorPos_Y_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionYSpinnerClicked_Effect()
{
	OpenTextBoxInputInterface( m_Editor_Position_Y, string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation.Y), 10, 
																		PCTextField_OnAccept_NewValue_PosY_Effect, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosY_Effect, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosY_Effect(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosY_Effect(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosY_Effect(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation;
	newPos.Y = float(userInput);

	PhotoboothEx.UpdatePropLocation(iSelectedEffectDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

function PositionSliderChanged_Z_Effect(UISlider SliderControl)
{
	local int Direction;
	local vector newPos;

	if ( SliderControl.percent < SliderEditorPos_Z_PrevPct )
		Direction = -1;
	else if ( SliderControl.percent > SliderEditorPos_Z_PrevPct )
		Direction = 1;

	newPos = PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation;
	newPos.Z += Direction * Step;

	PhotoboothEx.UpdatePropLocation(iSelectedEffectDataIndex, newPos);

	SliderControl.SetText(string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation.Z));

	SliderEditorPos_Z_PrevPct = SliderControl.percent;

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnPositionZSpinnerClicked_Effect()
{
	OpenTextBoxInputInterface( m_Editor_Position_Z, string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation.Z), 10, 
																		PCTextField_OnAccept_NewValue_PosZ_Effect, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_PosZ_Effect, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_PosZ_Effect(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_PosZ_Effect(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_PosZ_Effect(string userInput)
{
	local vector newPos;

	newPos = PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjLocation;
	newPos.Z = float(userInput);

	PhotoboothEx.UpdatePropLocation(iSelectedEffectDataIndex, newPos);

	TriggerScreenNeedsPopulate();
}

//
// Rotation Editor functionality
//
function RotateSliderPitch_Effect(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation;
	NewRot.Pitch	= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdatePropRotation(iSelectedEffectDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Pitch * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function RotateSliderYaw_Effect(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation;
	NewRot.Yaw		= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdatePropRotation(iSelectedEffectDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Yaw * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function RotateSliderRoll_Effect(UISlider SliderControl)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation;
	NewRot.Roll		= SliderControl.percent * class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;

	PhotoboothEx.UpdatePropRotation(iSelectedEffectDataIndex, NewRot);

	SliderControl.SetText(string(abs(NewRot.Roll * UnrRotToDeg)));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}


function OnRotationPitchClicked_Effect()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Pitch, string(abs(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation.Pitch * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Pitch_Effect, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Pitch_Effect, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Pitch_Effect(string text, bool bWasSuccessful)
{

	PCTextField_OnAccept_Rotation_Pitch_Effect(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Pitch_Effect(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation;
	NewRot.Roll		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdatePropRotation(iSelectedEffectDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function OnRotationYawClicked_Effect()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Yaw, string(abs(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation.Yaw * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Yaw_Effect, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Yaw_Effect, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Yaw_Effect(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Yaw_Effect(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Yaw_Effect(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation;
	NewRot.Yaw		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdatePropRotation(iSelectedEffectDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function OnRotationRollClicked_Effect()
{
	OpenTextBoxInputInterface( m_Editor_Rotation_Roll, string(abs(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation.Roll * UnrRotToDeg)), 6, 
																		PCTextField_OnAccept_Rotation_Roll_Effect, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Rotation_Roll_Effect, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Rotation_Roll_Effect(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_Rotation_Roll_Effect(bWasSuccessful ? text : "");
}

// bsg-nlong (1.11.17): end
function PCTextField_OnAccept_Rotation_Roll_Effect(string userInput)
{
	local Rotator NewRot;

	NewRot			= PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjRotation;
	NewRot.Roll		= float(userInput) * DegToUnrRot;

	PhotoboothEx.UpdatePropRotation(iSelectedEffectDataIndex, NewRot);

	TriggerScreenNeedsPopulate();
}

function ScaleSliderChanged_Effect(UISlider SliderControl)
{
	local float ScalePercent;

	ScalePercent = SliderControl.Percent;

	if (ScalePercent > 100)
		ScalePercent = 100;
	else if (ScalePercent < 1)
		ScalePercent = 1;		// Game and Editor crashes if Scale is 0
	
	ScalePercent = (ScalePercent) / 50;

	PhotoboothEx.UpdatePropScale(iSelectedEffectDataIndex, ScalePercent);

	SliderControl.SetText(string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjScale));

	CurrentScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);
}

function OnScaleSpinnerClicked_Effect()
{
	OpenTextBoxInputInterface( m_Editor_Scale_X, string(PhotoboothEx.arrProps[iSelectedEffectDataIndex].ObjScale), 10, 
																		PCTextField_OnAccept_NewValue_Scale_Effect, 
																		PCTextField_OnCancel_AnyTextBox,
																		VirtualKeyboard_OnNewValueSet_Scale_Effect, 
																		VirtualKeyboard_OnNewValueCancelled);
}

function VirtualKeyboard_OnNewValueSet_Scale_Effect(string text, bool bWasSuccessful)
{
	PCTextField_OnAccept_NewValue_Scale_Effect(bWasSuccessful ? text : "");
}

function PCTextField_OnAccept_NewValue_Scale_Effect(string userInput)
{
	if (float(userInput) > 0.0f)
	{
		return;
	}

	PhotoboothEx.UpdatePropScale(iSelectedEffectDataIndex, float(userInput));

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetPosition_Effect()
{
	PhotoboothEx.UpdatePropLocation(iSelectedEffectDataIndex, SetInitialEffectPosition());

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetRotation_Effect()
{
	local Rotator CurrentRot;

	CurrentRot = Rotator(SetInitialEffectPosition());
	CurrentRot.Pitch	= 0;  
	CurrentRot.Roll		= 0;

	PhotoboothEx.UpdatePropRotation(iSelectedEffectDataIndex, CurrentRot);

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnResetScale_Effect()
{
	PhotoboothEx.UpdatePropScale(iSelectedEffectDataIndex, 1.0f);

	// Force an update
	TriggerScreenNeedsPopulate();
}

function OnToggleHideEffect(UICheckbox CheckboxControl)
{
	PhotoboothEx.UpdatePropVisibility(iSelectedEffectDataIndex, CheckboxControl.bChecked);
}

function OnDeleteEffectClicked()
{
	PhotoboothEx.RemoveProp(iSelectedEffectDataIndex);

	iSelectedEffectDataIndex = 0;

	OnEffects();
}
*/
defaultproperties
{
	Step = 5.0f;
}