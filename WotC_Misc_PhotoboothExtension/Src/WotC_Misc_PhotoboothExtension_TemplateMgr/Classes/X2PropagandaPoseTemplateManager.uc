//
// This class is a hack to use a bare bones template manager with a native Get() function 
//
class X2PropagandaPoseTemplateManager extends X2ChallengeTemplateManager
	config (Content);

struct EquivalentClassPair
{
	var name OrgTemplateName;
	var name NewTemplateName;
};

// Allows reusing poses without having to define a new template for modded characters or classes.
var config array<EquivalentClassPair>			EquivalentSoldierClasses;
var config array<EquivalentClassPair>			EquivalentCharacterTemplates;

static function X2PropagandaPoseTemplateManager GetPropgandaPoseTemplateManager( )
{
	return X2PropagandaPoseTemplateManager(class'Engine'.static.GetTemplateManager(class'X2PropagandaPoseTemplateManager'));
}

function X2PropagandaPoseTemplate FindPoseTemplate( name DataName )
{
	local X2DataTemplate kTemplate;

	kTemplate = FindDataTemplate( DataName );
	if (kTemplate != none)
	{
		return X2PropagandaPoseTemplate( kTemplate );
	}
	return none;
}

defaultproperties
{
	TemplateDefinitionClass=class'X2PropagandaPoseDataSet'
	ManagedTemplateClass=class'X2PropagandaPoseTemplate'
}