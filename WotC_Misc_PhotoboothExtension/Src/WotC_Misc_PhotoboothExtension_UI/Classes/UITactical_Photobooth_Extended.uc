class UITactical_Photobooth_Extended extends UITactical_Photobooth;

// Handles the screen logic
var UIPhotoboothExtendedMaster	UIPhotoboothExMaster;

simulated function OnInit()
{
	super.OnInit();

	UIPhotoboothExMaster = Spawn(class'UIPhotoboothExtendedMaster', self);
	UIPhotoboothExMaster.OnInit(self, SetInitialObjectPosition);
}

simulated function CloseScreen()
{
	super.CloseScreen();

	UIPhotoboothExMaster.Destroy();
}

function Vector SetInitialObjectPosition()
{
	return m_kTacticalLocation.m_arrAllExits[m_kTacticalLocation.m_iCurrentStudioIndex].Location;
}

function SetTextColor(int iColorIndex)
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_BackgroundOptions;
	if (ColorSelectorState == 0)
	{
		`PHOTOBOOTH.SetTextBoxColor(m_iLastTouchedTextBox, iColorIndex);
		UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Graphics;
	}
	else if(ColorSelectorState == 1)
		`PHOTOBOOTH.SetGradientColorIndex1(iColorIndex);
	else if (ColorSelectorState == 2)
		`PHOTOBOOTH.SetGradientColorIndex2(iColorIndex);

	ColorSelector.Hide();
	NeedsPopulateData();

	//bsg-jedwards (5.1.17) : If using a controller and finished selecting a color, disable the color Navigator and select the List
	if(`ISCONTROLLERACTIVE)
	{
		ColorSelector.DisableNavigation();
		List.SetSelectedNavigation();
	}
	//bsg-jedwards (5.1.17) : end
}

// override for custom behavior
function OnCancel()
{
	UIPhotoboothExMaster.OnCancel();
}

function OnFormationLoaded()
{
	local int i;

	UIPhotoboothExMaster.PhotoboothEx.bCustomPositionSet = false;	// Disable updating custom positions

	if (--NumPawnsNeedingUpdateAfterFormationChange <= 0)
	{
		for (i = 0; i < `PHOTOBOOTH.m_arrUnits.Length; ++i)
		{
			if (`PHOTOBOOTH.m_arrUnits[i].FramesToHide > 0)
			{
				SetTimer(0.001f, false, nameof(OnFormationLoaded));
				return;
			}

			// Update location and scale of pawn
			UIPhotoboothExMaster.PhotoboothEx.UpdateLocation(i, `PHOTOBOOTH.m_arrUnits[i].Location);
		}
		
		if (bUpdateCameraWithFormation)
		{
			OnCameraPreset("Full Frontal");
		}
	}
}

//bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed
function OnConfirmFormation()
{
	List.OnSelectionChanged = none;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Base;
	List.ItemContainer.RemoveChildren();
	NeedsPopulateData();
}

function OnClickFormation()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Formation;
	NeedsPopulateData();
}

function OnClickBackgroundOptions()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_BackgroundOptions;
	NeedsPopulateData();
}

function OnClickSoldiers()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_SoldierData;
	NeedsPopulateData();
}

function OnClickTextLayout()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Layout;
	NeedsPopulateData();
}

function OnClickGraphics()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Graphics;
	NeedsPopulateData();
}

function OnChooseTextBoxColor0()
{
	m_iLastTouchedTextBox = 0;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_TextColor;
	NeedsPopulateData();
}
function OnChooseTextBoxColor1()
{
	m_iLastTouchedTextBox = 1;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_TextColor;
	NeedsPopulateData();
}
function OnChooseTextBoxColor2()
{
	m_iLastTouchedTextBox = 2;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_TextColor;
	NeedsPopulateData();
}
function OnChooseTextBoxColor3()
{
	m_iLastTouchedTextBox = 3;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_TextColor;
	NeedsPopulateData();
}

function OnChooseTextBoxFont0()
{
	m_iLastTouchedTextBox = 0;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_TextFont;
	NeedsPopulateData();
}
function OnChooseTextBoxFont1()
{
	m_iLastTouchedTextBox = 1;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_TextFont;
	NeedsPopulateData();
}
function OnChooseTextBoxFont2()
{
	m_iLastTouchedTextBox = 2;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_TextFont;
	NeedsPopulateData();
}
function OnChooseTextBoxFont3()
{
	m_iLastTouchedTextBox = 3;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_TextFont;
	NeedsPopulateData();
}

function OnChooseBackgroundColor1()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_GradientColor1;
	NeedsPopulateData();
}
function OnChooseBackgroundColor2()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_GradientColor2;
	NeedsPopulateData();
}

function OnClickBackground()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Background;
	NeedsPopulateData();
}

// -----------------------------------------------------------------
// Poster Text/Icon functions
//bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed
function OnConfirmLayout()
{
	List.OnSelectionChanged = none;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Base;
	List.ItemContainer.RemoveChildren();
	NeedsPopulateData();
}

//bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed
function OnConfirmBackground()
{
	List.OnSelectionChanged = none;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_BackgroundOptions;
	List.ItemContainer.RemoveChildren();
	NeedsPopulateData();
}

//bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed
function OnConfirmFirstPassFilter()
{
	List.OnSelectionChanged = none;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Base;
	List.ItemContainer.RemoveChildren();
	NeedsPopulateData();
}

function OnClickFirstPassFilter()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Filter;
	NeedsPopulateData();
}

//bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed
function OnConfirmSecondPassFilter()
{
	List.OnSelectionChanged = none;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Base;
	List.ItemContainer.RemoveChildren();
	NeedsPopulateData();
}

function OnClickSecondPassFilter()
{
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Treatment;
	NeedsPopulateData();
}

function OnChangeStudioLocation(UIListItemSpinner SpinnerControl, int Direction)
{
	local XGParamTag ParamTag;
	local Vector VecX, VecY, VecZ, CamOffset;

	GetAxes(m_vOldCaptureRotator, VecX, VecY, VecZ);

	bChangingLocation = true;
	m_fLastCamRotation = m_kStudioCamera.GetCameraRotation() - m_vOldCaptureRotator;
	CamOffset = m_kStudioCamera.GetCameraOffset() - m_vOldCaptureLocation;
	m_fLastViewDistance = m_kStudioCamera.GetCameraDistance();
	m_vLastCamOffset.X = VecX Dot CamOffset;
	m_vLastCamOffset.Y = VecY Dot CamOffset;
	m_vLastCamOffset.Z = VecZ Dot CamOffset;

	if (Direction == 1)
		m_kTacticalLocation.NextStudio(StudioLoadedUpdateCamera);
	else if(Direction == -1)
		m_kTacticalLocation.PreviousStudio(StudioLoadedUpdateCamera);

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = m_kTacticalLocation.m_iCurrentStudioIndex + 1;
	SpinnerControl.SetValue(`XEXPAND.ExpandString(m_LocationStr));
}

// Main menu
function PopulateDefaultList(out int Index)
{
	local XGParamTag ParamTag;

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = m_kTacticalLocation.m_iCurrentStudioIndex + 1;

	UIPhotoboothExMaster.GetListItem(Index++).UpdateDataSpinner(m_LocationTitle, `XEXPAND.ExpandString(m_LocationStr), OnChangeStudioLocation);

	UIPhotoboothExMaster.PopulateDefaultList(Index);
}

function GenerateDefaultSoldierSetup()
{
	local int i;
	local array<XComGameState_Unit> arrSoldiers;

	BATTLE().GetHumanPlayer().GetOriginalUnits(arrSoldiers, true, true, true);

	arrSoldiers.RandomizeOrder();

	for (i = 0; i < arrSoldiers.Length; ++i)
	{
		if (arrSoldiers[i].UnitIsValidForPhotobooth())
		{
			// Stop if we approach formation PIS limit
			if (DefaultSetupSettings.PossibleSoldiers.Length < `PHOTOBOOTH.m_kFormationTemplate.NumSoldiers)
			{
				`PHOTOBOOTH.SetSoldier(i, arrSoldiers[i].GetReference());
				
				// Fix for soldiers that appear beyond 6+ formations
				UIPhotoboothExMaster.PhotoboothEx.EnqueueScale(i, 1.0f);
				UIPhotoboothExMaster.PhotoboothEx.EnqueueLocation(i, `PHOTOBOOTH.m_arrUnits[i].Location);
			}

			DefaultSetupSettings.PossibleSoldiers.AddItem(arrSoldiers[i].GetReference());
		}
	}

	m_bInitialized = true;

	NeedsPopulateData();
}

// Gather number of units in the field
function UpdateSoldierData()
{
	local int i;
	local array<XComGameState_Unit> arrSoldiers, arrEnemies;
	local XComGameState_Unit		UnitState;

	BATTLE().GetHumanPlayer().GetOriginalUnits(arrSoldiers, true, true, true);
	BATTLE().GetAIPlayer().GetOriginalUnits(arrEnemies, true);

	// Gather as many soldiers in the field as possible
	for (i = 0; i < arrSoldiers.Length; i++)
	{
		if (arrSoldiers[i].UnitIsValidForPhotobooth())
		{
			m_arrSoldiers.AddItem(arrSoldiers[i].GetReference());
		}
	}

	foreach arrEnemies(UnitState)
	{
		// Don't care about validation since they're already dead
		m_arrSoldiers.AddItem(UnitState.GetReference());
	}

//	Super.UpdateSoldierData();
}

function OnSelectedSoldierListChange(UIList ContainerList, int ItemIndex)
{
	// Let other subsystems know we're focused on a soldier
	m_iLastTouchedSoldierIndex = List.SelectedIndex;
	UIPhotoboothExMaster.m_iLastTouchedSoldierIndex = m_iLastTouchedSoldierIndex;
}

//
// Set Soldier/Unit functionality
//
function OnClickPickNewSoldier()
{
	List.OnSelectionChanged = none;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_Soldier;
	List.ItemContainer.RemoveChildren();
	NeedsPopulateData();
}


//
// Set Pose Functionality
//

//bsg-jneal (5.16.17): confirm on pose menu now exits since pose selection was done on list selection changed
function OnConfirmPose()
{
	List.OnSelectionChanged = none;
	UIPhotoboothExMaster.CurrentScreenState = eUIPropagandaType_SoldierEditor;
	List.ItemContainer.RemoveChildren();
	NeedsPopulateData();
}

function OnReset()
{
	local int loopIndex;
	local StateObjectReference BlankSoldier;
	BlankSoldier.ObjectID = 0;
	m_bResetting = true;
	m_kGenRandomState = eAGCS_TickPhase1;
	`PHOTOBOOTH.ChangeFormation(DefaultSetupSettings.FormationTemplate);
	HidePosterElements(false); //bsg-hlee (05.12.17): Don't hide the poster on reset.

	//bsg-jedwards (5.1.17) : Resets the index to the beginning when reset
	if(`ISCONTROLLERACTIVE)
	{
		ModeSpinnerVal = 0;

		List.SetSelectedIndex(-1); //bsg-jneal (5.23.17): reset list index to properly reset the highlight
	}
	//bsg-jedwards (5.1.17) : end

	for (loopIndex = 0; loopIndex < 6; loopIndex++)
	{
		if (loopIndex >= DefaultSetupSettings.PossibleSoldiers.length)
		{
			`PHOTOBOOTH.SetSoldier(loopIndex, BlankSoldier);
		}
		else
		{
			`PHOTOBOOTH.SetSoldier(loopIndex, DefaultSetupSettings.PossibleSoldiers[loopIndex]);
		}
	}
}

// Whenever the player clicks a button in Photobooth, this function is called on the next tick
function PopulateData()
{
	//bsg-jneal (5.16.17): now returning to original menu index when leaving soldier or pose selection
	local int i, previousListIndex;

	previousListIndex = -1;

	//bsg-jedwards (5.1.17) : Check if the state changed so we can clear the list items and remake them as some may have changed drastically
	if(UIPhotoboothExMaster.CurrentScreenState != UIPhotoboothExMaster.LastScreenState)
	{
		UIPhotoboothExMaster.LastScreenState = UIPhotoboothExMaster.CurrentScreenState;
		List.ClearItems();
	}
	else
	{
		HideListItems();
	}
	//bsg-jedwards (5.1.17) : end
	
	i = 0;	

	`LOG("[" $ GetFuncName() $ "()] State: " $ EUIPropagandaExtendedScreenType(UIPhotoboothExMaster.CurrentScreenState), true, default.class.name);

	if (m_bInitialized)
	{
		switch (UIPhotoboothExMaster.CurrentScreenState)
		{
		case eUIPropagandaType_Base:
			PopulateDefaultList(i);
			break;
		case eUIPropagandaType_Formation:
			PopulateFormationList(i);
			break;
		case eUIPropagandaType_SoldierData:
			UIPhotoboothExMaster.PopulateSoldierDataList(i, OnSelectedSoldierListChange);
			break;
		case eUIPropagandaType_Soldier:
			UIPhotoboothExMaster.PopulateSoldierList(i);
			break;
		case eUIPropagandaType_Pose:
			PopulatePoseList(i);
			break;
		case eUIPropagandaType_BackgroundOptions:
			PopulateBackgroundOptionsList(i);
			break;
		case eUIPropagandaType_Background:
			PopulateBackgroundList(i);
			break;
		case eUIPropagandaType_Graphics:
			UIPhotoboothExMaster.PopulateGraphicsList(i);
			break;
		case eUIPropagandaType_Fonts:
			PopulateFontList(i);
			break;
		case eUIPropagandaType_TextColor:
			PopulateTextColors(i);
			break;
		case eUIPropagandaType_GradientColor1:
			PopulateBackground1Colors(i);
			break;
		case eUIPropagandaType_GradientColor2:
			PopulateBackground2Colors(i);
			break;
		case eUIPropagandaType_TextFont:
			PopulateFontList(i);
			break;
		case eUIPropagandaType_Layout:
			PopulateLayoutList(i);
			break;
		case eUIPropagandaType_Filter:
			PopulateFilterList(i);
			break;
		case eUIPropagandaType_Treatment:
			PopulateTreatmentList(i);
			break;
		// PE: New Screens
		case eUIPropagandaType_SoldierEditor:
			UIPhotoboothExMaster.PopulateSoldierEditorList(i);
			break;
		case eUIPropagandaType_SoldierBoneSelection:
			//PopulateSoldierDataList(i);
			break;
		case eUIPropagandaType_SoldierBoneEditor:
			//PopulateSoldierDataList(i);
			break;
		case eUIPropagandaType_Animations:
			//PopulateSoldierDataList(i);
			break;
		case eUIPropagandaType_ObjectsList:
			UIPhotoboothExMaster.PopulateObjectsList(i);
			break;
		case eUIPropagandaType_ObjectEditor:
			UIPhotoboothExMaster.PopulateObjectEditorList(i);
			break;
		case eUIPropagandaType_PickObjectData:
			UIPhotoboothExMaster.PopulatePickObjectList(i);
			break;
		case eUIPropagandaType_LightsList:
			UIPhotoboothExMaster.PopulateLightsList(i);
			break;
		case eUIPropagandaType_LightEditor:
			UIPhotoboothExMaster.PopulateLightEditorList(i);
			break;
		case eUIPropagandaType_ExtendedOptions:
			UIPhotoboothExMaster.PopulateExtendedOptionsList(i);
			break;
		case eUIPropagandaType_LandscapeMode:
			UIPhotoboothExMaster.PopulateLandscapeModeMenu(i);
			break;
		};

		//bsg-jedwards (5.1.17) : Repopulate the navigator on the list when the list refreshens
		if(`ISCONTROLLERACTIVE)
		{
			if(previousListIndex != -1)
			{
				List.SetSelectedIndex(previousListIndex);
			}
			else 
			{
				//bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed, if entering these menus set the initial pose index so the list does not init on the wrong pose
				if(UIPhotoboothExMaster.CurrentScreenState == eUIPropagandaType_Pose || UIPhotoboothExMaster.CurrentScreenState == eUIPropagandaType_Formation || UIPhotoboothExMaster.CurrentScreenState == eUIPropagandaType_Layout || UIPhotoboothExMaster.CurrentScreenState == eUIPropagandaType_Filter || UIPhotoboothExMaster.CurrentScreenState == eUIPropagandaType_Background || UIPhotoboothExMaster.CurrentScreenState == eUIPropagandaType_Treatment)
				{
					List.NavigatorSelectionChanged(m_bOriginalSubListIndex);
				}
				else if(UIPhotoboothExMaster.CurrentScreenState == eUIPropagandaType_Base)
				{
					List.SetSelectedIndex(m_iDefaultListIndex); //bsg-jneal (5.23.17): saving default list index for better nav
				}
				else
				{
					List.OnSelectionChanged = none; //bsg-jneal (5.23.17): clear selection changed callback for sub lists that do not use it
					List.SetSelectedIndex(List.SelectedIndex);
				}
			}
		}
		//bsg-jedwards (5.1.17) : end
	}
	//bsg-jneal (5.16.17): end
}

function GetFirstPassFilterData(out array<String> outFilterNames, out int outFilterIndex)
{
	local array<FilterPosterOptions> arrFilters;
	local int i;

	outFilterIndex = `PHOTOBOOTH.GetFirstPassFilters(arrFilters);

	for (i = 0; i < arrFilters.Length; ++i)
	{
		`LOG("" $ arrFilters[i].FilterDisplayName,, 'WotC_Misc_PhotoboothExtension');
		outFilterNames.AddItem(arrFilters[i].FilterDisplayName);
	}
}

function PopulateFilterList(out int Index)
{
	local array<string> FilterNames;
	local int FilterIndex, i;
	GetFirstPassFilterData(FilterNames, FilterIndex);

	for (i = 0; i < FilterNames.Length; i++)
	{
		GetListItem(Index++).UpdateDataDescription(FilterNames[i], OnConfirmFirstPassFilter); //bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed
	}

	//bsg-jneal (5.23.17): updating certain list indices for poster previews on selection changed
	m_bOriginalSubListIndex = FilterIndex;
	List.OnSelectionChanged = OnSetFirstPassFilter;
	//bsg-jneal (5.23.17): end
}

//
// Hot code
//
event Tick(float DeltaTime)
{
	local Vector2D MouseDelta;
	if (bIsFocused)
	{
		PhotoboothBaseTick(DeltaTime);

		// KDERDA - Move this to it's respective subclass to avoid log spam.
		if (XComTacticalInput(PC.PlayerInput) != none)
		{
			StickVectorLeft.x = XComTacticalInput(PC.PlayerInput).m_fLSXAxis;
			StickVectorLeft.y = XComTacticalInput(PC.PlayerInput).m_fLSYAxis;
			StickVectorRight.x = XComTacticalInput(PC.PlayerInput).m_fRSXAxis;
			StickVectorRight.y = XComTacticalInput(PC.PlayerInput).m_fRSYAxis;
		}

		if (m_bRightMouseIn && !m_bRotatingPawn)
		{
			MouseDelta = Movie.Pres.m_kUIMouseCursor.m_v2MouseFrameDelta;
			Movie.Pres.m_kUIMouseCursor.UpdateMouseLocation();
			
			//bsg-jneal (5.2.17): controller input for camera, right stick for rotation, left for pan
			if (!`ISCONTROLLERACTIVE)
			{
				m_kStudioCamera.AddRotation(MouseDelta.Y * DragRotationMultiplier, -1 * MouseDelta.X * DragRotationMultiplier, 0);
			}
			else
			{
				m_kStudioCamera.AddRotation(StickVectorRight.Y * StickRotationMultiplier * DeltaTime, StickVectorRight.X * StickRotationMultiplier * DeltaTime, 0);
			}
			//bsg-jneal (5.2.17): end
		}

		if (m_bMouseIn && !m_bRotatingPawn)
		{
			MouseDelta = Movie.Pres.m_kUIMouseCursor.m_v2MouseFrameDelta;
			Movie.Pres.m_kUIMouseCursor.UpdateMouseLocation();
			
			//bsg-jneal (5.2.17): controller input for camera, right stick for rotation, left for pan
			if (!`ISCONTROLLERACTIVE)
			{
				m_kStudioCamera.MoveFocusPointOnRotationAxes(0, -1 * MouseDelta.X * DragPanMultiplier * m_kStudioCamera.GetZoomPercentage(), MouseDelta.Y * DragPanMultiplier * m_kStudioCamera.GetZoomPercentage());
			}
			else
			{
				m_kStudioCamera.MoveFocusPointOnRotationAxes(0, -StickVectorLeft.X * DragPanMultiplierController * DeltaTime, -StickVectorLeft.Y * DragPanMultiplierController * DeltaTime);
			}
			//bsg-jneal (5.2.17): end
		}
	}
}

function PhotoboothBaseTick(float DeltaTime)
{
	if (m_bNeedsPopulateData)
	{
		m_bNeedsPopulateData = false;
		UpdateNavHelp(); // bsg-jneal (4.4.17): force a navhelp update to correctly fix wide icon sizing issues when first entering the photobooth
		PopulateData();

		if(`ISCONTROLLERACTIVE && List.SelectedIndex < 1) //bsg-jedwards (5.1.17) : Stay on current selected index until list change
		{
			Navigator.SelectFirstAvailable(); // bsg-jneal (4.4.17): make sure the navigator selects the first available target when the list is recreated
		}
	}

	if (m_bResetting && UpdateReset()) 
	{
		UIPhotoboothExMaster.PhotoboothEx.ResetPhotoboothEx();
		return;
	}

	if (UpdateRandom()) 
	{
		UIPhotoboothExMaster.PhotoboothEx.ResetPhotoboothEx();
		return;
	}
	
	UIPhotoboothExMaster.UpdateSoldierPositionAndRotation();

	MoveCaptureComponent();
}

