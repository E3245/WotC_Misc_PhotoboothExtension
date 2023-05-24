class X2PropagandaPoseTemplate extends X2DataTemplate config(Content);

struct PhExAnimationPoses
{
	var localized string				AnimationDisplayName;
	var name							AnimationName;
	var float							AnimationOffset;
	var bool							bShowTemplarShardBlades;
	var bool							bExcludeFromGroupShots;
	var bool							bUseSoldierWeapon;
};

// Specific Soldier Class, leave blank to specify all of them
var config name RequireSoldierClassTemplateName;
var config name ExcludeSoldierClassTemplateName;

// List of character templates that this is valid for
var config array<name> ValidCharacterTemplateNames;	

var config bool bRequiresTLE;				 // Requires the TLE DLC enabled 
var config bool bIsMemorialSet;
var config bool bIsCapturedSet;
var config bool bIsDuoSet;					 // Special error checking, if there is an odd number of Duo Poses, then the template is rejected

var config array<PhExAnimationPoses> m_arrAnimationPoses;

var localized string CategoryFriendlyName;

function bool ValidateTemplate(out string strError)
{
	if (m_arrAnimationPoses.Length <= 0)
	{
		strError = "m_arrAnimationPoses is empty!";
		return false;
	}
	else if (m_arrAnimationPoses.Length > 200)
	{
		strError = "over 200 limit for m_arrAnimationPoses!";
		return false;
	}

	if (bIsDuoSet && (m_arrAnimationPoses.Length % 2 != 0) )
	{
		strError = "bIsDuoSet is enabled but m_arrAnimationPoses has odd number of elements!";
		return false;
	}

	return true;
}