//
// This class is a hack to use a bare bones template manager with a native Get() function 
//
class X2PropagandaPoseTemplateManager extends X2DataTemplateManager
	config (Game);

struct EquivalentClassPair
{
	var name OrgTemplateName;
	var name NewTemplateName;
};

// Allows reusing poses without having to define a new template for modded characters or classes.
var config array<EquivalentClassPair>			EquivalentSoldierClasses;
var config array<EquivalentClassPair>			EquivalentCharacterTemplates;

var config array<name>							DefaultHumanCharTemplateNames;

static function bool IsLikeSoldierClass(Name CharTemplateName, Name TemplateNameToFind)
{
	local EquivalentClassPair EquivChara;

	foreach default.EquivalentSoldierClasses(EquivChara)
	{
		if (EquivChara.OrgTemplateName == CharTemplateName &&
			EquivChara.NewTemplateName == TemplateNameToFind)
		{
			return true;
		}
	}

	return false;
}

static function bool IsLikeCharacterTemplate(Name CharTemplateName, Name TemplateNameToFind)
{
	local EquivalentClassPair EquivChara;

	foreach default.EquivalentCharacterTemplates(EquivChara)
	{
		if (EquivChara.OrgTemplateName == CharTemplateName &&
			EquivChara.NewTemplateName == TemplateNameToFind)
		{
			return true;
		}
	}

	return false;
}

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

function array<X2PropagandaPoseTemplate> GetAllPoseTemplates()
{
	local array<X2PropagandaPoseTemplate> arrPoseTemplates;
	local X2DataTemplate Template;
	local X2PropagandaPoseTemplate PoseTemplate;

	foreach IterateTemplates(Template, none)
	{
		PoseTemplate = X2PropagandaPoseTemplate(Template);

		if (PoseTemplate == none)
			continue;

		arrPoseTemplates.AddItem(PoseTemplate);
	}

	return arrPoseTemplates;
}

function array<X2PropagandaPoseTemplate> GetAllFilteredPoseTemplates()
{
	local array<X2PropagandaPoseTemplate> arrPoseTemplates;
	local X2DataTemplate Template;
	local X2PropagandaPoseTemplate PoseTemplate;

	foreach IterateTemplates(Template, none)
	{
		PoseTemplate = X2PropagandaPoseTemplate(Template);

		if (PoseTemplate == none || PoseTemplate.bIsSPARKSet)
			continue;

		arrPoseTemplates.AddItem(PoseTemplate);
	}

	return arrPoseTemplates;
}

function array<X2PropagandaPoseTemplate> GetSpecificCharPoseTemplates(name TemplateName)
{
	local array<X2PropagandaPoseTemplate> arrPoseTemplates;
	local X2DataTemplate Template;
	local X2PropagandaPoseTemplate PoseTemplate;

	foreach IterateTemplates(Template, none)
	{
		PoseTemplate = X2PropagandaPoseTemplate(Template);

		if (PoseTemplate == none || PoseTemplate.ValidCharacterTemplateNames.Find(TemplateName) == INDEX_NONE)
			continue;

		arrPoseTemplates.AddItem(PoseTemplate);
	}

	return arrPoseTemplates;
}

function array<X2PropagandaPoseTemplate> GetSPARKPoseTemplates()
{
	local array<X2PropagandaPoseTemplate> arrPoseTemplates;
	local X2DataTemplate Template;
	local X2PropagandaPoseTemplate PoseTemplate;

	foreach IterateTemplates(Template, none)
	{
		PoseTemplate = X2PropagandaPoseTemplate(Template);

		if (PoseTemplate == none || !PoseTemplate.bIsSPARKSet)
			continue;

		arrPoseTemplates.AddItem(PoseTemplate);
	}

	return arrPoseTemplates;
}

function array<X2PropagandaPoseTemplate> GetTemplarPoseTemplates()
{
	local array<X2PropagandaPoseTemplate> arrPoseTemplates;
	local X2DataTemplate Template;
	local X2PropagandaPoseTemplate PoseTemplate;

	foreach IterateTemplates(Template, none)
	{
		PoseTemplate = X2PropagandaPoseTemplate(Template);

		if (PoseTemplate == none || !PoseTemplate.bIsTemplarSet)
			continue;

		arrPoseTemplates.AddItem(PoseTemplate);
	}

	return arrPoseTemplates;
}

defaultproperties
{
	TemplateDefinitionClass=class'X2PropagandaPoseDataSet'
	ManagedTemplateClass=class'X2PropagandaPoseTemplate'
}