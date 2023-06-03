//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: This class creates the X2InfiltrationModTemplates from config
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2PropagandaPoseDataSet extends X2DataSet config(Content);

var config array<name> arrPoseTemplates;

static function array<X2DataTemplate> CreateTemplates()
{
	local X2PropagandaPoseTemplate Template;
	local array<X2DataTemplate> Templates;
	local name IterTemplateName;

	// Create Special Template
	Templates.AddItem(CreateEmptyPhotoboothPoseTemplate());
	
	// Create the rest of the templates
	foreach default.arrPoseTemplates(IterTemplateName)
	{
		`CREATE_X2TEMPLATE(class'X2PropagandaPoseTemplate', Template, IterTemplateName);

		Templates.AddItem(Template);
	}

	return Templates;
}

static function X2DataTemplate CreateEmptyPhotoboothPoseTemplate()
{
	local X2PropagandaPoseTemplate Template;

	`CREATE_X2TEMPLATE(class'X2PropagandaPoseTemplate', Template, 'PhEx_SPECIAL_NONE');

	return Template;
}