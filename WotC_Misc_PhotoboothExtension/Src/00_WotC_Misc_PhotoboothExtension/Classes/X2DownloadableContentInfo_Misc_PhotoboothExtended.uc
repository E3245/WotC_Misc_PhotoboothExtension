class X2DownloadableContentInfo_Misc_PhotoboothExtended extends X2DownloadableContentInfo config(Content);

var config array<X2PhotoboothStaticMeshTemplate>	arrPhotoboothStaticMeshes;
var config array<X2PhotoboothFXTemplate>			arrPhotoboothParticleEffects;

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