//---------------------------------------------------------------------------------------
//  FILE:    XComGameState_LEBBM.uc
//  AUTHOR:  LeaderEnemyBoss
//  PURPOSE: stores the config values to prevent excessive updating of headshots (only when something changed make new headshots
//			 hopefully prevents performance issues on slow machines
//---------------------------------------------------------------------------------------

class XComGameState_LEBPortrait extends XComGameState_BaseObject;

var int CameraDistance;
var int CameraFOV;
