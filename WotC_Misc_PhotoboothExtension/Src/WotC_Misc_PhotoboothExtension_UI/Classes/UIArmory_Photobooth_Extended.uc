class UIArmory_Photobooth_Extended extends UIArmory_Photobooth;

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

// On the pawns current position
function Vector SetInitialObjectPosition()
{
	return `PHOTOBOOTH.m_arrUnits[0].ActorPawn.Location;
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

// Main menu
function PopulateDefaultList(out int Index)
{
	UIPhotoboothExMaster.PopulateDefaultList(Index);
}

function GenerateDefaultSoldierSetup()
{
	`PHOTOBOOTH.SetSoldier(0, m_kDefaultSoldierRef);

	if(DefaultSetupSettings.PossibleSoldiers.Length == 0)
		DefaultSetupSettings.PossibleSoldiers.AddItem(m_kDefaultSoldierRef);

	Super.GenerateDefaultSoldierSetup();
}

// Gather number of units in the field
function UpdateSoldierData()
{
	local int i;
	local XComGameState_Unit Unit;
	local XComGameState_HeadquartersXCom HQState;

	m_arrSoldiers.Length = 0;

	if(m_kDefaultSoldierRef.ObjectID != 0)
	{
		m_arrSoldiers.AddItem(m_kDefaultSoldierRef);
	}

	//Need to get the latest state here, else you may have old data in the list upon refreshing at OnReceiveFocus, such as 
	//still showing dismissed soldiers. 
	HQState = class'UIUtilities_Strategy'.static.GetXComHQ();

	for (i = 0; i < HQState.Crew.Length; i++)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(HQState.Crew[i].ObjectID));

		if (Unit.IsAlive())
		{
			if (Unit.IsSoldier() && m_arrSoldiers.Find('ObjectID', Unit.ObjectID) == INDEX_NONE)
			{
				m_arrSoldiers.AddItem(Unit.GetReference());
			}
		}
	}

	Super.UpdateSoldierData();
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
		if (`HQINPUT != none)
		{
			StickVectorLeft.x = `HQINPUT.m_fLSXAxis;
			StickVectorLeft.y = `HQINPUT.m_fLSYAxis;
			StickVectorRight.x = `HQINPUT.m_fRSXAxis;
			StickVectorRight.y = `HQINPUT.m_fRSYAxis;
		}

		if (m_bRightMouseIn && !m_bRotatingPawn)
		{
			m_kCamState.SetUseCameraPreset(false);
			MouseDelta = Movie.Pres.m_kUIMouseCursor.m_v2MouseFrameDelta;
			Movie.Pres.m_kUIMouseCursor.UpdateMouseLocation();
			
			//bsg-jneal (5.2.17): controller input for camera, right stick for rotation, left for pan
			if (!`ISCONTROLLERACTIVE)
			{
				m_kCamState.AddRotation(MouseDelta.Y * DragRotationMultiplier,  -1 * MouseDelta.X * DragRotationMultiplier, 0);
			}
			else
			{
				m_kCamState.AddRotation(StickVectorRight.Y * StickRotationMultiplier * DeltaTime, StickVectorRight.X * StickRotationMultiplier * DeltaTime, 0);
			}
			//bsg-jneal (5.2.17): end
		}

		if (m_bMouseIn && !m_bRotatingPawn)
		{
			m_kCamState.SetUseCameraPreset(false);
			MouseDelta = Movie.Pres.m_kUIMouseCursor.m_v2MouseFrameDelta;
			Movie.Pres.m_kUIMouseCursor.UpdateMouseLocation();
			
			//bsg-jneal (5.2.17): controller input for camera, right stick for rotation, left for pan
			if (!`ISCONTROLLERACTIVE)
			{
				m_kCamState.MoveFocusPointOnRotationAxes(0, -1 * MouseDelta.X * DragPanMultiplier * m_kCamState.GetZoomPercentage(), MouseDelta.Y * DragPanMultiplier * m_kCamState.GetZoomPercentage());
			}
			else
			{
				m_kCamState.MoveFocusPointOnRotationAxes(0, -StickVectorLeft.X * DragPanMultiplierController * DeltaTime, -StickVectorLeft.Y * DragPanMultiplierController * DeltaTime);
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

