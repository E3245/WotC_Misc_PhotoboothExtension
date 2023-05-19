class PhotoboothExtendedSettings extends Object config (PhotoboothExtendedSettings);

var config float	SoldierRotationMultiplier;		

var config int		iPosterSizeLandscapeX;
var config int		iPosterSizeLandscapeY;

var config bool		bSystemOnly_IsInLandscapeMode;	// Hack

static function SetFloat_SoldierRotationMultiplier(float NewValue)
{
	default.SoldierRotationMultiplier = NewValue;

	StaticSaveConfig();
}

static function SetInt_PosterSizeLandscape_X(int NewValue)
{
	default.iPosterSizeLandscapeX = NewValue;

	StaticSaveConfig();
}

static function SetInt_PosterSizeLandscape_Y(int NewValue)
{
	default.iPosterSizeLandscapeY = NewValue;

	StaticSaveConfig();
}

// Hacky, but it works
static function SetBool_System_IsInLandscapeMode(bool NewBool)
{
	default.bSystemOnly_IsInLandscapeMode = NewBool;

	StaticSaveConfig();
}