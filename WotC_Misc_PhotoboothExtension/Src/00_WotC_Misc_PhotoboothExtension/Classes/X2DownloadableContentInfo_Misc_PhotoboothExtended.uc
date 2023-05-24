class X2DownloadableContentInfo_Misc_PhotoboothExtended extends X2DownloadableContentInfo config(Content);

var config array<X2PhotoboothStaticMeshTemplate>	arrPhotoboothStaticMeshes;
var config array<X2PhotoboothFXTemplate>			arrPhotoboothParticleEffects;

// Add new animsets to specific character templates
var config array<DLCAnimSetAdditions>				arrAnimSetAdditions;

var localized string m_FormationDisplayName_Wedge_12Count;
var localized string m_FormationDisplayName_Line_12Count;
var localized string m_FormationDisplayName_Mob_12Count;

var localized string m_FormationDisplayName_Wedge_24Count;
var localized string m_FormationDisplayName_Line_24Count;
var localized string m_FormationDisplayName_Mob_24Count;

static function X2PhotoboothStaticMeshTemplate GetTemplateByName(name TemplateName)
{
	local int Idx;
	Idx = default.arrPhotoboothStaticMeshes.Find('TemplateName', TemplateName);

	return default.arrPhotoboothStaticMeshes[Idx];
}

static event OnPostTemplatesCreated()
{
	FixPhotoboothFormationLocalization();

	OnPostCharacterTemplatesCreated();
}

static function FixPhotoboothFormationLocalization()
{
	local X2PropagandaPhotoTemplateManager PropagandaMgr;
	local int i;
	local string OldDisplayName;
	
	PropagandaMgr = class'X2PropagandaPhotoTemplateManager'.static.GetPropagandaPhotoTemplateManager();

	for (i = 0; i < PropagandaMgr.PhotoboothTemplateConfig.Length; i++)
	{
		switch(PropagandaMgr.PhotoboothTemplateConfig[i].TemplateName)
		{
			case 'Wedge12':
				PropagandaMgr.PhotoboothTemplateConfig[i].DisplayName = default.m_FormationDisplayName_Wedge_12Count;
				break;
			case 'Line12':
				PropagandaMgr.PhotoboothTemplateConfig[i].DisplayName = default.m_FormationDisplayName_Line_12Count;
				break;
			case 'Mob12':
				PropagandaMgr.PhotoboothTemplateConfig[i].DisplayName = default.m_FormationDisplayName_Mob_12Count;
				break;
			case 'Wedge24':
				PropagandaMgr.PhotoboothTemplateConfig[i].DisplayName = default.m_FormationDisplayName_Wedge_24Count;
				break;
			case 'Line24':
				PropagandaMgr.PhotoboothTemplateConfig[i].DisplayName = default.m_FormationDisplayName_Line_24Count;
				break;
			case 'Mob24':
				PropagandaMgr.PhotoboothTemplateConfig[i].DisplayName = default.m_FormationDisplayName_Mob_24Count;
				break;
			default:
				break;
		}
	}
}

// OnPostTemplatesCreated() event: Add Animsets to specific soldier templates
static function OnPostCharacterTemplatesCreated()
{
	local X2CharacterTemplateManager CharacterTemplateMgr;
	local X2CharacterTemplate SoldierTemplate;
	local array<X2DataTemplate> DataTemplates;
	local int ScanTemplates, ScanAdditions;

	CharacterTemplateMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	
	for ( ScanAdditions = 0; ScanAdditions < default.arrAnimSetAdditions.Length; ++ScanAdditions )
	{
		CharacterTemplateMgr.FindDataTemplateAllDifficulties(default.arrAnimSetAdditions[ScanAdditions].CharacterTemplate, DataTemplates);
		for ( ScanTemplates = 0; ScanTemplates < DataTemplates.Length; ++ScanTemplates )
		{
			SoldierTemplate = X2CharacterTemplate(DataTemplates[ScanTemplates]);
			if (SoldierTemplate != none)
			{
				SoldierTemplate.AdditionalAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype(default.arrAnimSetAdditions[ScanAdditions].AnimSet)));
				SoldierTemplate.AdditionalAnimSetsFemale.AddItem(AnimSet(`CONTENT.RequestGameArchetype(default.arrAnimSetAdditions[ScanAdditions].FemaleAnimSet)));
			}
		}
	}
}