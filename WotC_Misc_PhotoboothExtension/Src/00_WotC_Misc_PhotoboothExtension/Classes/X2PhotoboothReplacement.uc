class X2PhotoboothReplacement extends X2Photobooth config(LEBPortrait_Defaults);

`include(ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

//This mod contains manually edited versions of the backgrounds to make them look better when used as a photo background
//This config array ensures the game knows, which backgrounds to replace with our new ones
struct native ReplacementBackgrounds
{
	var string				OriginalBackgroundName;
	var string				ReplacementBackgroundName;
};

var config array<ReplacementBackgrounds> ReplaceBackgrounds;

//MCM stuff
`MCM_CH_VersionChecker(class'LEBPortrait_Defaults'.default.VERSION,class'UIScreenlistenerMCM_LEBPortrait'.default.CONFIG_VERSION)

function bool AllowTint()
{
    return `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.bAllowTint,class'UIScreenlistenerMCM_LEBPortrait'.default.bAllowTint);
}
function int GetTintIndex1()
{
    return `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.TintIndex1,class'UIScreenlistenerMCM_LEBPortrait'.default.TintIndex1);
}
function int GetTintIndex2()
{
    return `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.TintIndex2,class'UIScreenlistenerMCM_LEBPortrait'.default.TintIndex2);
}
function bool RandomBG()
{
    return `MCM_CH_GetValue(class'LEBPortrait_Defaults'.default.bRandomBG,class'UIScreenlistenerMCM_LEBPortrait'.default.bRandomBG);
}

//LEB some mods (Photorebooth) alter settings onposttemplatescreated, this may lead to compatibility issues. Copy altered settings here to prevent this
static function X2Photobooth GetPhotobooth()
{
	local X2PhotoboothReplacement Photobooth;

	Photobooth = X2PhotoboothReplacement(super.GetPhotobooth());
	Photobooth.CopyPhotoboothConfigs();
	return Photobooth;
}

function CopyPhotoboothConfigs()
{
	local X2Photobooth Photobooth;

	Photobooth = X2Photobooth(class'Engine'.static.FindClassDefaultObject("XComGame.X2Photobooth"));

	if (Photobooth == none)
		return;

	m_arrFirstPassFilterOptions		= Photobooth.m_arrFirstPassFilterOptions;
	m_arrSecondPassFilterOptions	= Photobooth.m_arrSecondPassFilterOptions;
	m_arrBackgroundOptions			= Photobooth.m_arrBackgroundOptions;
	m_arrSoloALines					= Photobooth.m_arrSoloALines;
	m_arrSoloBLines					= Photobooth.m_arrSoloBLines;
	m_arrSoloOpLines				= Photobooth.m_arrSoloOpLines;
	m_arrSquadALines				= Photobooth.m_arrSquadALines;
	m_arrSquadBLines				= Photobooth.m_arrSquadBLines;
	m_arrSquadOpLines				= Photobooth.m_arrSquadOpLines;
}

function SetupCaptureBounds()
{
	local PlayerController pc;
	local XComLocalPlayer localPlayer;
	local float aspectRatio;

	// Extra Variables
	local bool	bIsInLandscapeMode;

	//`LOG("[" $ GetFuncName() $ "()] Function Called", true, default.class.name);

	bIsInLandscapeMode = class'PhotoboothExtendedSettings'.default.bSystemOnly_IsInLandscapeMode;
	
	pc = GetALocalPlayerController();
	localPlayer = XComLocalPlayer(pc.Player);
	if (localPlayer != none)
	{
		if (bIsInLandscapeMode)
		{
			// Set the poster size dictated by the settings. It can change anytime.
			m_iPosterSizeX		= class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeX;
			m_iPosterSizeY		= class'PhotoboothExtendedSettings'.default.iPosterSizeLandscapeY;

			m_iOnScreenSizeX	= m_iPosterSizeX;
			m_iOnScreenSizeY	= m_iPosterSizeY;

			m_iOnScreenX		= 0;
			m_iOnScreenY		= 0;
		}
		else
		{
			//Reset to defaults
			m_iPosterSizeX		= 800;
			m_iPosterSizeY		= 1200;

			//if (PhotoboothEx.bLandscapeMode)
			aspectRatio = float(m_iPosterSizeX) / float(m_iPosterSizeY);
			m_iOnScreenSizeY = localPlayer.SceneView.SizeY * m_fMaxYPercentage;
			m_iOnScreenSizeX = m_iOnScreenSizeY * aspectRatio;

			//`LOG("[" $ GetFuncName() $ "()] Aspect Ratio: " $ aspectRatio $ ", Scene View X: " $ localPlayer.SceneView.SizeX $ ", Scene View Y: " $ localPlayer.SceneView.SizeY, true, default.class.name);

			if (m_iOnScreenSizeX > (localPlayer.SceneView.SizeX * m_fMaxXPercentage))
			{
				m_iOnScreenSizeX = localPlayer.SceneView.SizeX * m_fMaxXPercentage;
				m_iOnScreenSizeY = m_iOnScreenSizeX / aspectRatio;
			}
					
			m_iOnScreenX = (localPlayer.SceneView.SizeX - m_iOnScreenSizeX) * 0.5;
			m_iOnScreenY = (localPlayer.SceneView.SizeY - m_iOnScreenSizeY) * 0.5;
		}

	}

	//`LOG("[" $ GetFuncName() $ "()] Screen X: " $ m_iOnScreenX $ ", Screen Y :" $ m_iOnScreenY $ "\nScreen Size X: " $ m_iOnScreenSizeX $ ", Screen Size Y: " $ m_iOnScreenSizeY, true, default.class.name);

	if (m_kPhotoboothShowEffect != none)
	{
		m_kPhotoboothShowEffect.X = m_iOnScreenX;
		m_kPhotoboothShowEffect.Y = m_iOnScreenY;

		m_kPhotoboothShowEffect.SizeX = m_iOnScreenSizeX;
		m_kPhotoboothShowEffect.SizeY = m_iOnScreenSizeY;
	}

	ResizeRenderTargets();
}

//
// LEB Portrait functions and overrides go here
//

function SetAutoGenSettings(PhotoboothAutoGenSettings InSettings, optional delegate<OnPosterCreated> inOnPosterCreated)
{
	
	If (InSettings.CameraPresetDisplayName == "Headshot") 
	{
		//`LEBMSG("Vanilla Headshot");
		InSettings.CameraPresetDisplayName = "HeadshotLEB";
	}
	
	AutoGenSettings = InSettings;
	m_kOnPosterCreated = inOnPosterCreated;
}

//modified to support replacement backgrounds
function LEBSetBackgroundTexture(string BackgroundDisplayName)
{
	local int BackgroundIndex;
	local bool bFoundReplacement;
	local ReplacementBackgrounds ReplaceBackground;

	for (BackgroundIndex = 0; BackgroundIndex < m_arrBackgroundOptions.Length; ++BackgroundIndex)
	{
		if (m_arrBackgroundOptions[BackgroundIndex].BackgroundDisplayName == BackgroundDisplayName)
			break;
	}

	if (BackgroundIndex >= m_arrBackgroundOptions.Length) return;

	if (m_arrBackgroundOptions[BackgroundIndex].BackgroundTexture == none)
	{
		bFoundReplacement = false;

		foreach ReplaceBackgrounds(ReplaceBackground)
		{
			If (ReplaceBackground.OriginalBackgroundName != m_arrBackgroundOptions[BackgroundIndex].BackgroundName) continue;
			m_arrBackgroundOptions[BackgroundIndex].BackgroundTexture = Texture2D(`CONTENT.RequestGameArchetype(ReplaceBackground.ReplacementBackgroundName));
			bFoundReplacement = true;
			break;
		}
		If (!bFoundReplacement) m_arrBackgroundOptions[BackgroundIndex].BackgroundTexture = Texture2D(`CONTENT.RequestGameArchetype(m_arrBackgroundOptions[BackgroundIndex].BackgroundName));
	}

	if (m_kPhotoboothEffect != none)
	{
		m_kPhotoboothEffect.BackgroundTexture = m_arrBackgroundOptions[BackgroundIndex].BackgroundTexture;

		SetCaptureRenderChannels();
		SetFirstPassFilterTints();
	}
}

function bool LEBRandomTint(string BackgroundDisplayName)
{
	local int BackgroundIndex;

	for (BackgroundIndex = 0; BackgroundIndex < m_arrBackgroundOptions.Length; ++BackgroundIndex)
	{
		if (m_arrBackgroundOptions[BackgroundIndex].BackgroundDisplayName == BackgroundDisplayName)
			break;
	}

	if (BackgroundIndex >= m_arrBackgroundOptions.Length) return false;
	return m_arrBackgroundOptions[BackgroundIndex].bAllowTintingOnRandomize;
}

// modified Autogenerate event
event AutoGenerate()
{
	local array<PhotoboothCameraPreset> arrCameraPresets;
	local PhotoboothCameraPreset CameraPreset;
	local PhotoboothCameraSettings CameraSettings;
	local int i, CameraIndex;

	if (CanTakeAutoPhoto(true))
	{
		m_kFinalPosterComponent.bUseMainScenePostProcessSettings = false;

		// Need to call this in case we are re-entering after being interrupted.
		HidePreview();

		SetGameIndex(AutoGenSettings.CampaignID);

		MoveFormation(AutoGenSettings.FormationLocation);
		ChangeFormation(AutoGenSelectFormation(AutoGenSettings));

		//If (AutoGenSettings.TextLayoutState != ePBTLS_HeadShot) 
		ResizeFinalRenderTarget(AutoGenSettings.TextLayoutState == ePBTLS_HeadShot);

		SetFirstPassFilter(0);
		SetSecondPassFilter(0);

		m_kAutoGenCaptureState = eAGCS_TickPhase1;
	}

	if (m_kAutoGenCaptureState == eAGCS_TickPhase1)
	{
		if (DeferPhase1()) return;

		switch (AutoGenSettings.TextLayoutState)
		{
		case ePBTLS_PromotedSoldier:
			SetTextLayoutByType(eTLT_Promotion);
			break;
		case ePBTLS_CapturedSoldier:
			SetTextLayoutByType(eTLT_Captured);
			SetBackgroundColorOverride(true);
			SetGradientColor1(CapturedTintColor1);
			SetGradientColor2(CapturedTintColor2);
			break;
		case ePBTLS_HeadShot:
			HidePosterTexture();
			//SetTextLayoutByType(eTLT_Promotion);
			If (RandomBG())
			{
				SetBackgroundColorOverride(LEBRandomTint(AutoGenSettings.BackgroundDisplayName));
				SetGradientColorIndex1(`SYNC_RAND(m_FontColors.length));
				SetGradientColorIndex2(`SYNC_RAND(m_FontColors.length));
			}
			else If (AllowTint())
			{
				SetBackgroundColorOverride(true);
				SetGradientColorIndex1(GetTintIndex1());
				SetGradientColorIndex2(GetTintIndex2());
			}
			else SetBackgroundColorOverride(false);
			break;
		}

		AutoGenSetSoldiers();

		if (AutoGenSettings.bChallengeMode)
		{
			AutoGenChallengeModeTextLayout();
		}
		else if (AutoGenSettings.TextLayoutState != ePBTLS_HeadShot)
		{
			AutoGenTextLayout();
			SetBackgroundTexture(AutoGenSettings.BackgroundDisplayName);
		}
		if (AutoGenSettings.TextLayoutState == ePBTLS_HeadShot) LEBSetBackgroundTexture(AutoGenSettings.BackgroundDisplayName);
		m_kAutoGenCaptureState = eAGCS_TickPhase2;
	}

	if (m_kAutoGenCaptureState == eAGCS_TickPhase2)
	{
		if (DeferPhase2()) return;
		
		AutoGenSetAnims();

		m_kAutoGenCaptureState = eAGCS_TickPhase3;
	}

	if(m_kAutoGenCaptureState == eAGCS_TickPhase3)
	{
		if (DeferPhase3()) return;

		SetCameraPOV(AutoGenSettings.CameraPOV, true); // Need to setup Capture's FOV so that camera position can be properly determined
		GetCameraPresets(arrCameraPresets, AutoGenSettings.CameraPresetDisplayName != "Captured");

		if (AutoGenSettings.TextLayoutState == ePBTLS_HeadShot)
		{
			CameraPreset.FocusBoneOrSocket = name("CIN_Target");
			CameraPreset.FrameSetting = ePFS_Head;
		}
		
		//LEB: removed special treatment for headshots
		CameraIndex = 0;
		if (AutoGenSettings.CameraPresetDisplayName != "")
		{
			for (i = 0; i < arrCameraPresets.Length; ++i)
			{
				if (arrCameraPresets[i].TemplateName == AutoGenSettings.CameraPresetDisplayName)
				{
					CameraIndex = i;
					break;
				}
			}
		}
		else
		{
			CameraIndex = `SYNC_RAND(arrCameraPresets.Length);
		}

		CameraPreset = arrCameraPresets[CameraIndex];

		if (GetCameraPOVForPreset(CameraPreset, CameraSettings))
		{
			AutoGenSettings.CameraPOV.Rotation = CameraSettings.Rotation;

			if (AutoGenSettings.TextLayoutState == ePBTLS_HeadShot)
			{
				CameraSettings.ViewDistance = AutoGenSettings.CameraDistance;
			}

			AutoGenSettings.CameraPOV.Location = CameraSettings.RotationPoint - CameraSettings.ViewDistance * vector(CameraSettings.Rotation);

			if (XComTacticalController(GetALocalPlayerController()) != none)
			{
				FixedTacticalAutoGenCamera = new class'X2Camera_Fixed';
				FixedTacticalAutoGenCamera.SetCameraView(AutoGenSettings.CameraPOV);
				FixedTacticalAutoGenCamera.Priority = eCameraPriority_Cinematic;
				`CAMERASTACK.AddCamera(FixedTacticalAutoGenCamera);
			}

			SetCameraPOV(AutoGenSettings.CameraPOV, true);

			m_kFinalPosterComponent.m_nRenders = 2;
			CreatePoster(AutoGenGetFrameDelay(), m_kOnPosterCreated);

			m_kAutoGenCaptureState = eAGCS_Capturing;
		}
	}
}

defaultproperties
{
	//If you change these numbers mirror the change in XComPresentationLayerBase
	m_iPosterSizeX = 800;
	m_iPosterSizeY = 1200;
}