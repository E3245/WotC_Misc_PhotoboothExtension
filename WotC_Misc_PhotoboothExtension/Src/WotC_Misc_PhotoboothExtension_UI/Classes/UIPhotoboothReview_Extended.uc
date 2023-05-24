class UIPhotoboothReview_Extended extends UIPhotoboothReview;

var int DefaultPosterRes_X;
var int DefaultPosterRes_Y;

var int DefaultPosterPos_X;

simulated function OnInit()
{
	super.OnInit();

	// Move buttons to highest depth
	m_PreviousButton.MoveToHighestDepth();
	m_NextButton.MoveToHighestDepth();
	m_DeleteButton.MoveToHighestDepth();
	m_FavoriteButton.MoveToHighestDepth();
	m_OpenButton.MoveToHighestDepth();

	// Index gets hidden when widescreen photos are displayed
	MC.ChildFunctionVoid("posterIndex", "MoveToHighestDepth");
	MC.ChildFunctionVoid("favIcon", "MoveToHighestDepth");
	MC.ChildFunctionVoid("favLabel", "MoveToHighestDepth");

	SetPosterImage();
}

simulated function PreviousButton(UIButton ButtonControl)
{
	m_CurrentPosterIndex = m_CurrentPosterIndex - 1;
	if (m_CurrentPosterIndex < 1)
		m_CurrentPosterIndex = m_MaxPosterIndex;

	SetPosterImage();

	MC.BeginFunctionOp("setPosterFavorite");
	MC.QueueBoolean(`XENGINE.m_kPhotoManager.GetPosterIsFavorite(m_iGameIndex, PosterIndices[m_CurrentPosterIndex - 1]));
	MC.EndOp();
}

simulated function NextButton(UIButton ButtonControl)
{
	m_CurrentPosterIndex = m_CurrentPosterIndex + 1;
	if (m_CurrentPosterIndex > m_MaxPosterIndex)
		m_CurrentPosterIndex = 1;

	SetPosterImage();

	MC.BeginFunctionOp("setPosterFavorite");
	MC.QueueBoolean(`XENGINE.m_kPhotoManager.GetPosterIsFavorite(m_iGameIndex, PosterIndices[m_CurrentPosterIndex - 1]));
	MC.EndOp();
}

function SetPosterImage()
{
	local Texture2D NewPoster;
	local int	FlashPosterSize_X, FlashPosterSize_Y, FlashPosterPos_X;

	// Get the image and check for it's resolution
	NewPoster = GetCurrentPoster();

	FlashPosterSize_X	= DefaultPosterRes_X;
	FlashPosterSize_Y	= DefaultPosterRes_Y;

	FlashPosterPos_X	= DefaultPosterPos_X;

	`LOG("[" $ GetFuncName() $ "()] Photo: " $ PathName(NewPoster) $ " Size (" $ NewPoster.SizeX $ ", " $ NewPoster.SizeY $ ")", true, default.class.name);

	// Scale the image if it's a wide poster
	if (NewPoster.SizeX > DefaultPosterRes_X)
	{
		// Scale down the poster if it exceeds 1920
		if (NewPoster.SizeX > 1920)
			FlashPosterSize_X = 1920;
		else
			FlashPosterSize_X = NewPoster.SizeX;

		FlashPosterPos_X = 0;	// Move to top left corner
	}

	if (NewPoster.SizeY > DefaultPosterRes_Y)
		FlashPosterSize_Y = 1072;
	else
		FlashPosterSize_Y = NewPoster.SizeY;

	MC.BeginFunctionOp("setPosterImage");
	MC.QueueString(class'UIUtilities_Image'.static.ValidateImagePath(PathName(NewPoster)));
	MC.QueueString(String(m_CurrentPosterIndex)$"/"$String(m_MaxPosterIndex));
	MC.EndOp();

	// Direct MC calls are slow
	MC.ChildSetNum("PosterImage", "_x", FlashPosterPos_X);
//	MC.ChildSetNum("PosterImage", "_y", 0);

	MC.ChildSetNum("PosterImage", "_width", FlashPosterSize_X);
	MC.ChildSetNum("PosterImage", "_height", FlashPosterSize_Y);
}

function Texture2D GetCurrentPoster()
{
	return `XENGINE.m_kPhotoManager.GetPosterTexture(m_iGameIndex, PosterIndices[m_CurrentPosterIndex - 1]);
}

defaultproperties
{
	DefaultPosterRes_X = 710
	DefaultPosterRes_Y = 1072

	DefaultPosterPos_X = 605
}