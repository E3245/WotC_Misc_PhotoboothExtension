class UIPhotoboothMovie_PE extends UIPhotoboothMovie;

var private int DefaultResX;
var private int DefaultResY;

simulated function InitMovie(XComPresentationlayerBase InitPres)
{
	super.InitMovie(InitPres);
}

function ChangeResolution(int ResX, int ResY, optional bool bSetAdjustFullRenderVP = false)
{
	UI_RES_X = ResX;
	UI_RES_Y = ResY;

	PhotoboothDimensionX = ResX;
	PhotoboothDimensionY = ResY;

	bAdjustToFullRenderViewport = bSetAdjustFullRenderVP;

	class'TextureRenderTarget2D'.static.Resize(`XENGINE.m_kPhotoboothUITexture, ResX, ResY);
	RenderTexture = `XENGINE.m_kPhotoboothUITexture;

	RefreshResolutionAndSafeArea();
}

function ResetResolution()
{
	bAdjustToFullRenderViewport = false;

	ChangeResolution(DefaultResX, DefaultResY);
}

defaultproperties
{
	DefaultResX = 800;
	DefaultResY = 1200;

	bIsVisible = true;
	bAdjustToFullRenderViewport = false	// Stops stretching the layout textures
}