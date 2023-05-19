class X2PhotoboothReplacement extends X2Photobooth;

//
// Main point of init insertion
//
event InitializeRenderData()
{
	super.InitializeRenderData();

	CopyX2PhotoboothVars();
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

// Copy any elements added to the Photobooth via OPTC or by other methods
function CopyX2PhotoboothVars()
{
	local X2Photobooth Photobooth;

	Photobooth = X2Photobooth(class'Engine'.static.FindClassDefaultObject("XComGame.X2Photobooth"));

	if (Photobooth == none)
		return;

	m_arrFirstPassFilterOptions		= Photobooth.m_arrFirstPassFilterOptions;
	m_arrSecondPassFilterOptions	= Photobooth.m_arrSecondPassFilterOptions;
	m_arrBackgroundOptions			= Photobooth.m_arrBackgroundOptions;
}

defaultproperties
{
	//If you change these numbers mirror the change in XComPresentationLayerBase
	m_iPosterSizeX = 800;
	m_iPosterSizeY = 1200;
}