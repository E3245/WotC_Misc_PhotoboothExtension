
// Actor that handles Props, Lights, and other objects for the Photobooth
class X2PhotoboothExtended extends Actor;

// States that we should keep track of
var bool							bCustomPositionSet;

var array<Vector>					ActorLocation;	// Agonistic from current units in the photobooth
var array<float>					ActorScale;

var bool							bLandscapeMode;

var array<Actor_PhotoboothProp>		arrProps;
var array<Actor_PhotoboothLight>	arrLightEmitters;
var array<Actor_PhotoboothFX>		arrParticleFXs;

event Destroyed()
{
	local Actor_PhotoboothProp Prop;
	local int i;

	foreach arrProps(Prop, i)
	{
		Prop.Destroy();
	}

	arrProps.Length = 0;
}

function ResetPhotoboothEx()
{
	local PoseSoldierData Unit;
	local int i;

	bCustomPositionSet	= false;

	// Create an empty array of vectors on creation
	ActorLocation.Length	= `PHOTOBOOTH.m_arrUnits.Length;
	ActorScale.Length		= `PHOTOBOOTH.m_arrUnits.Length;
	arrProps.Length			= 0;

	foreach `PHOTOBOOTH.m_arrUnits(Unit, i)
	{
		ActorLocation[i] = Unit.Location;
		ActorScale[i]	 = 1.0f;
	}
}

function UpdateLocation(int LocationIndex, Vector Position)
{
	ActorLocation[LocationIndex] = Position;
}

function EnqueueLocation(int LocationIndex, Vector Position)
{
	if (LocationIndex >= ActorLocation.Length)
	{
		ActorLocation.Add(LocationIndex - ActorLocation.Length + 1);
	}

	UpdateLocation(LocationIndex, Position);
}

function UpdateScale(int LocationIndex, float newScale)
{
	ActorScale[LocationIndex] = newScale;
}

function EnqueueScale(int LocationIndex, float newScale)
{
	if (LocationIndex >= ActorScale.Length)
	{
		ActorScale.Add(LocationIndex - ActorScale.Length + 1);
	}

	UpdateScale(LocationIndex, newScale);
}

//
// Prop Utilities
//

// Components would get hidden when a Post Processing chain changes the render channels
// See LN 942, X2Photobooth.uc::SetUnitRenderChannels()
function RenderChannelContainer GetDefaultRenderChannels()
{
	local RenderChannelContainer RenderChannels;

	RenderChannels.MainScene = true;
	RenderChannels.SecondaryScene = true;

	return RenderChannels;
}

function CreateNewProp(	StaticMesh kMesh, 
						X2PhotoboothStaticMeshTemplate Template, 
						vector newVect, 
						rotator newRot, 
						optional float newScale = 1.0f, optional bool bIsHidden = false)
{
	local Actor_PhotoboothProp NewPropData;

	NewPropData = Spawn(class'Actor_PhotoboothProp', self);

	NewPropData.TemplateInfo = Template;

	NewPropData.CustomMesh.SetStaticMesh(kMesh);
	NewPropData.CustomMesh.SetAbsolute(true, true, true);

	NewPropData.CustomMesh.SetTranslation(newVect);
	NewPropData.CustomMesh.SetRotation(newRot);
	NewPropData.CustomMesh.SetScale(newScale);
	NewPropData.CustomMesh.SetHidden(bIsHidden);
	NewPropData.CustomMesh.SetRenderChannels(GetDefaultRenderChannels());

	//Store this information in the actor
	NewPropData.ObjLocation		= newVect;
	NewPropData.ObjRotation		= newRot;
	NewPropData.ObjScale		= newScale;
	NewPropData.bIsHidden		= bIsHidden;

	arrProps.AddItem(NewPropData);
}

function UpdatePropInfo(int LocationIndex, X2PhotoboothStaticMeshTemplate newTemplate)
{
	local StaticMesh	NewMesh;

	NewMesh = StaticMesh(DynamicLoadObject(newTemplate.StaticMeshPath, class'StaticMesh', true));

	arrProps[LocationIndex].CustomMesh.SetStaticMesh(NewMesh);
	arrProps[LocationIndex].TemplateInfo = newTemplate;
}

function UpdatePropLocation(int LocationIndex, Vector newPos)
{
	arrProps[LocationIndex].CustomMesh.SetTranslation(newPos);
	arrProps[LocationIndex].ObjLocation = newPos;
}

function UpdatePropRotation(int LocationIndex, Rotator newRot)
{
	arrProps[LocationIndex].CustomMesh.SetRotation(newRot);
	arrProps[LocationIndex].ObjRotation = newRot;
}

function UpdatePropScale(int LocationIndex, float newScale)
{
	arrProps[LocationIndex].CustomMesh.SetScale(newScale);
	arrProps[LocationIndex].ObjScale = newScale;
}

function UpdatePropVisibility(int LocationIndex, bool bHide)
{
	arrProps[LocationIndex].CustomMesh.SetHidden(bHide);
	arrProps[LocationIndex].bIsHidden = bHide;
}

function RemoveProp(int LocationIndex)
{
	// Delete the prop
	arrProps[LocationIndex].Destroy();

	arrProps.Remove(LocationIndex, 1);
}

//
// Light Utilities
//
function CreateNewLight(vector newVect, 
						rotator newRot,
						string newColor,
						float newBrightness = 20.0f)
{
	local Actor_PhotoboothLight NewLightData;

	NewLightData = Spawn(class'Actor_PhotoboothLight', self);

	NewLightData.eActiveLightType = ePBLight_Spot;

	NewLightData.SetLightPosition(newVect);
	NewLightData.SetLightRotation(newRot);

	NewLightData.SpotLight.Brightness = newBrightness;
	NewLightData.PointLight.Brightness = newBrightness;

	NewLightData.SpotLight.LightColor = HexStringToByteColor(newColor);
	NewLightData.PointLight.LightColor = HexStringToByteColor(newColor);

	NewLightData.SpotLight.UpdateColorAndBrightness();
	NewLightData.PointLight.UpdateColorAndBrightness();

	//Store this information in the actor
	NewLightData.objColorHexStr		= newColor;
	NewLightData.ObjBrightness		= newBrightness;
	NewLightData.bIsEnabled			= true;

	NewLightData.SpotLight.SetEnabled(true);
	NewLightData.PointLight.SetEnabled(false);

	arrLightEmitters.AddItem(NewLightData);
}

function UpdateLightLocation(int LocationIndex, Vector newPos)
{
	arrLightEmitters[LocationIndex].SetLightPosition(newPos);
}

function UpdateLightRotation(int LocationIndex, Rotator newRot)
{
	arrLightEmitters[LocationIndex].SetLightRotation(newRot);
}

function UpdateLightBrightness(int LocationIndex, float newBrightness)
{
	arrLightEmitters[LocationIndex].SpotLight.Brightness = newBrightness;
	arrLightEmitters[LocationIndex].PointLight.Brightness = newBrightness;

	arrLightEmitters[LocationIndex].ObjBrightness	= newBrightness;

	arrLightEmitters[LocationIndex].SpotLight.UpdateColorAndBrightness();
	arrLightEmitters[LocationIndex].PointLight.UpdateColorAndBrightness();
}

function UpdateLightColor(int LocationIndex, string HexColor)
{
	arrLightEmitters[LocationIndex].SpotLight.LightColor = HexStringToByteColor(HexColor);
	arrLightEmitters[LocationIndex].SpotLight.UpdateColorAndBrightness();

	arrLightEmitters[LocationIndex].PointLight.LightColor = HexStringToByteColor(HexColor);
	arrLightEmitters[LocationIndex].PointLight.UpdateColorAndBrightness();

	arrLightEmitters[LocationIndex].objColorHexStr	= HexColor;
}

function UpdateLightVisibility(int LocationIndex, bool bEnable)
{
	switch(arrLightEmitters[LocationIndex].eActiveLightType)
	{
		case ePBLight_Spot:
			arrLightEmitters[LocationIndex].SpotLight.SetEnabled(bEnable);
			break;
		case ePBLight_Point:
			arrLightEmitters[LocationIndex].PointLight.SetEnabled(bEnable);
			break;
	}

	arrLightEmitters[LocationIndex].bIsEnabled = bEnable;
}

function UpdateLightMeshHelperVisibility(int LocationIndex, bool bHide)
{
	arrLightEmitters[LocationIndex].MeshIcon.SetHidden(bHide);
	arrLightEmitters[LocationIndex].bHelperMeshHidden = bHide;
}

function UpdateSpotLightParams(int LocationIndex, optional float InnerConeAngle = -1.0f, optional float OuterConeAngle = -1.0f)
{
	if (InnerConeAngle > -1.0f)
		arrLightEmitters[LocationIndex].SpotLight.InnerConeAngle = InnerConeAngle;

	if (OuterConeAngle > -1.0f)
		arrLightEmitters[LocationIndex].SpotLight.OuterConeAngle = OuterConeAngle;

	// Spots need an update whenever the cone radius is changed
	arrLightEmitters[LocationIndex].SpotLight.ForceUpdate(false);
}

function RemoveLight(int LocationIndex)
{
	// Delete the prop
	arrLightEmitters[LocationIndex].Destroy();

	arrLightEmitters.Remove(LocationIndex, 1);
}

static function Color		HexStringToByteColor(string Hex)
{
	local int iColor, R, G, B;
	// String to Int does not support hex, so attempt to convert each value into bytes
	iColor = HexFromStringConversion(Hex);

	// Only the first 6 bytes are considered
	R = (iColor & 0xFF0000) >> 16;
	G = (iColor & 0x00FF00) >> 8;
	B = (iColor & 0x0000FF);

	return MakeColor(R, G, B, 255);
}

static function LinearColor HexStringToLinearColor(string Hex)
{
	local int iColor, R, G, B;
	// String to Int does not support hex, so attempt to convert each value into bytes
	iColor = HexFromStringConversion(Hex);
	
	// Only the first 6 bytes are considered
	R = (iColor & 0xFF0000) >> 16;
	G = (iColor & 0x00FF00) >> 8;
	B = (iColor & 0x0000FF);
	
	// Turn integers into Linear Color by normalizing the resultants
	return MakeLinearColor( R / 255.0f, G / 255.0f, B / 255.0f, 1.0f);
}

static function int HexFromStringConversion(string toHex)
{
	local int iColor, i, Character;
	local string Text;

	iColor = 0;
	Text = toHex;

	while (Len(Text) > 0)
	{
		i = Len(Text) - 1;
		// Pull the first character
		Character = Asc(Left(Text, 1));

		// Consume letter
		Text = Mid(Text, 1);

		switch(Character)
		{
			// A
			case 0x41:
			// a
			case 0x61:
				iColor += 10 << 4 * i;
				break;
			// B
			case 0x42:
			// b
			case 0x62:
				iColor += 11 << 4 * i;
				break;
			// C
			case 0x43:
			// c
			case 0x63:
				iColor += 12 << 4 * i;
				break;
			// D
			case 0x44:
			// d
			case 0x64:
				iColor += 13 << 4 * i;
				break;
			// E
			case 0x45:
			// e
			case 0x65:
				iColor += 14 << 4 * i;
				break;
			// F
			case 0x46:
			// f
			case 0x66:
				iColor += 15 << 4 * i;
				break;
			default:
				iColor += int(Chr(Character)) << 4 * i;
				break;
		}
	}

	return iColor;
}

//
// Particle Effects Utilities
//
function CreateNewEffects(	X2PhotoboothFXTemplate Template, 
							vector newVect, 
							rotator newRot, 
							optional float newScale = 1.0f, optional bool bIsHidden = false)
{
	local Actor_PhotoboothFX NewEffectData;

	NewEffectData = Spawn(class'Actor_PhotoboothFX', self);

	NewEffectData.CreateNewParticle(Template);

	arrParticleFXs.AddItem(NewEffectData);
}

function UpdateEffectInfo(int LocationIndex, X2PhotoboothFXTemplate newTemplate)
{
	arrParticleFXs[LocationIndex].CreateNewParticle(newTemplate);
}

function UpdateEffectLocation(int LocationIndex, Vector newPos)
{
	arrParticleFXs[LocationIndex].SetEmitterPosition(newPos);
}

function UpdateEffectRotation(int LocationIndex, Rotator newRot)
{
	arrParticleFXs[LocationIndex].SetEmitterRotation(newRot);
}

/*
TODO: Make scale function for Emitter
function UpdateEffectScale(int LocationIndex, float newScale)
{
	arrParticleFXs[LocationIndex].MeshIcon.SetScale(newScale);
	arrParticleFXs[LocationIndex].ObjScale = newScale;
}

function UpdateEffectVisibility(int LocationIndex, bool bHide)
{
	arrParticleFXs[LocationIndex].MeshIcon.SetHidden(bHide);
	arrParticleFXs[LocationIndex].bIsHidden = bHide;
}
*/
function RemoveEffect(int LocationIndex)
{
	// Delete the Effect
	arrParticleFXs[LocationIndex].KillParticle();
	arrParticleFXs[LocationIndex].Destroy();

	arrParticleFXs.Remove(LocationIndex, 1);
}

static function array<int> GetAssignedSoldiers()
{
	local int i;
	local array<int> Soldiers;

	for (i = 0; i < `PHOTOBOOTH.m_arrUnits.Length; ++i)
	{
		if (`PHOTOBOOTH.m_arrUnits[i].UnitRef.ObjectID > 0)
			Soldiers.AddItem(`PHOTOBOOTH.m_arrUnits[i].UnitRef.ObjectID);
	}

	return Soldiers;
}

// Expanded logic for generating random lines
static function GenerateExpandedAutoTextStrings(Photobooth_AutoTextUsage Usage, optional Photobooth_TextLayoutState textLayoutState = ePBTLS_NONE, optional out PhotoboothDefaultSettings defaultSettings, optional bool bUseDefaultText = false)
{
	local int Roll, LineChanceIndex, i, opLineChance;
	local X2PhotoboothTag LocTag;
	local array<string> GeneratedText;
	local array<FontOptions> arrFontOptions;
	local array<int> GeneratedFont;
	local array<int> GeneratedFontColor;
	local XComGameState_Unit Unit1, Unit2;
	local X2SoldierClassTemplate Template;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionSite;
	local AutoGeneratedLines LinesStruct;
	local bool bAutoGenDeadSoldier, bExcludeNickNames, bCanChooseOperation, bCapturedOnlyFonts;
	local Photobooth_TextLayoutState generatedTextLayoutState;

	local array<int>	arrPossibleSoldiers;
	local int			Idx1, UnitRef1, UnitRef2;
	local X2Photobooth	Photobooth;

	Photobooth = `PHOTOBOOTH;

	// Get all soldiers current assigned in the photobooth
	arrPossibleSoldiers = static.GetAssignedSoldiers();

	// Get a unique soldier in the array then remove that element
	Idx1 = `SYNC_RAND_STATIC(arrPossibleSoldiers.Length);
	UnitRef1 = arrPossibleSoldiers[Idx1];

	arrPossibleSoldiers.Remove(Idx1, 1);

	UnitRef2 = arrPossibleSoldiers[`SYNC_RAND_STATIC(arrPossibleSoldiers.Length)];

	Unit1 = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef1));
	Unit2 = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef2));

	LocTag = X2PhotoboothTag(`XEXPANDCONTEXT.FindTag("Photobooth"));

	if (textLayoutState == ePBTLS_NONE)
	{
		generatedTextLayoutState = Photobooth.AutoGenSettings.TextLayoutState;
	}
	else
	{
		generatedTextLayoutState = textLayoutState;
	}

	bAutoGenDeadSoldier = generatedTextLayoutState == ePBTLS_DeadSoldier;
	opLineChance = Photobooth.arrAutoTextChances[Usage].OpLineChance;

	bExcludeNickNames = false;

	switch (Usage)
	{
	// Solo Poses
	case ePBAT_SOLO:
		LinesStruct.ALines = Photobooth.m_arrSoloALines;
		LinesStruct.BLines = bAutoGenDeadSoldier ? Photobooth.m_arrSoloMemorialBLines : Photobooth.m_arrSoloBLines;
		LinesStruct.OpLines = Photobooth.m_arrSoloOpLines;

		if (Unit1 != none)
		{
			LocTag.Kills = Unit1.GetNumKills();
			LocTag.Missions = Unit1.GetNumMissions();
			LocTag.FirstName0 = Unit1.GetFirstName();
			LocTag.LastName0 = Unit1.GetLastName();
			LocTag.Class0 = Unit1.GetSoldierClassTemplate().DisplayName;

			// Use alien name as nicknames
			if (Unit1.IsAlien())
				LocTag.NickName0 = Unit1.GetMyTemplate().strCharacterName;
			else
				LocTag.NickName0 = Unit1.GetNickName();

			if (LocTag.NickName0 == "''" || LocTag.NickName0 == "")
			{
				for (i = 0; i < LinesStruct.ALines.Length; ++i)
				{
					if (InStr(LinesStruct.ALines[i], "NickName0") >= 0)
					{
						LinesStruct.ALines.Remove(i--, 1);
					}
				}

				for (i = 0; i < LinesStruct.OpLines.Length; ++i)
				{
					if (InStr(LinesStruct.OpLines[i], "NickName0") >= 0)
					{
						LinesStruct.OpLines.Remove(i--, 1);
					}
				}
			}
			else if (!Unit1.IsResistanceHero() && Unit1.GetRank() < 3)
			{
				for (i = 0; i < LinesStruct.ALines.Length; ++i)
				{
					if (InStr(LinesStruct.ALines[i], Photobooth.m_CallsignString) >= 0)
					{
						LinesStruct.ALines.Remove(i--, 1);
					}
				}

				for (i = 0; i < LinesStruct.OpLines.Length; ++i)
				{
					if (InStr(LinesStruct.OpLines[i], Photobooth.m_CallsignString) >= 0)
					{
						LinesStruct.OpLines.Remove(i--, 1);
					}
				}
			}

			if (Unit1.GetNumKills() <= 0)
			{
				opLineChance = 0; // no nickname most likely no kills so this looks bad
			}

			LocTag.RankName0 = `GET_RANK_STR(Unit1.GetRank(), Unit1.GetSoldierClassTemplateName());
			//LocTag.Flag = ;

			if (LocTag.RankName0 == LocTag.Class0)
			{
				for (i = 0; i < LinesStruct.ALines.Length; ++i)
				{
					if (InStr(LinesStruct.ALines[i], "RankName0") >= 0 && InStr(LinesStruct.ALines[i], "Class0") >= 0)
					{
						LinesStruct.ALines.Remove(i--, 1);
					}
				}
			}

			Template = Unit1.GetSoldierClassTemplate();
			
			// Allow aliens to get Male lines too?
			if (Unit1.kAppearance.iGender == eGender_Male || 
				(Unit1.kAppearance.iGender == eGender_None && Unit1.IsAlien())
				) 
			{
				if (bAutoGenDeadSoldier)
				{
					for (i = 0; i < Photobooth.m_arrSoloMemorialBLines_Male.Length; ++i)
					{
						LinesStruct.BLines.AddItem(Photobooth.m_arrSoloMemorialBLines_Male[i]);
					}
				}
				else
				{
					for (i = 0; i < Photobooth.m_arrSoloALines_Male.Length; ++i)
					{
						LinesStruct.ALines.AddItem(Photobooth.m_arrSoloALines_Male[i]);
					}

					for (i = 0; i < Photobooth.m_arrSoloBLines_Male.Length; ++i)
					{
						LinesStruct.BLines.AddItem(Photobooth.m_arrSoloBLines_Male[i]);
					}

					if (Template != none)
					{
						for (i = 0; i < Template.PhotoboothSoloBLines_Male.Length; ++i)
						{
							LinesStruct.BLines.AddItem(Template.PhotoboothSoloBLines_Male[i]);
						}
					}
				}
			}
			else
			{
				if (bAutoGenDeadSoldier)
				{
					for (i = 0; i < Photobooth.m_arrSoloMemorialBLines_Female.Length; ++i)
					{
						LinesStruct.BLines.AddItem(Photobooth.m_arrSoloMemorialBLines_Female[i]);
					}
				}
				else
				{
					for (i = 0; i < Photobooth.m_arrSoloALines_Female.Length; ++i)
					{
						LinesStruct.ALines.AddItem(Photobooth.m_arrSoloALines_Female[i]);
					}

					for (i = 0; i < Photobooth.m_arrSoloBLines_Female.Length; ++i)
					{
						LinesStruct.BLines.AddItem(Photobooth.m_arrSoloBLines_Female[i]);
					}

					if (Template != none)
					{
						for (i = 0; i < Template.PhotoboothSoloBLines_Female.Length; ++i)
						{
							LinesStruct.BLines.AddItem(Template.PhotoboothSoloBLines_Female[i]);
						}
					}
				}
			}
		}
		break;
	case ePBAT_DUO:
		LinesStruct.ALines = Photobooth.m_arrDuoALines;
		LinesStruct.BLines = Photobooth.m_arrDuoBLines;
		LinesStruct.OpLines = Photobooth.m_arrDuoOpLines;

		if (Unit1 != none && Unit2 != none)
		{
			LocTag.Kills = Unit1.GetNumKills() + Unit2.GetNumKills();
			LocTag.Missions = Unit1.GetNumMissions() + Unit2.GetNumMissions();;
			LocTag.FirstName0 = Unit1.GetFirstName();
			LocTag.FirstName1 = Unit2.GetFirstName();
			LocTag.LastName0 = Unit1.GetLastName();
			LocTag.LastName1 = Unit2.GetLastName();

			LocTag.Class0 = Unit1.GetSoldierClassTemplate().DisplayName;
			LocTag.Class1 = Unit2.GetSoldierClassTemplate().DisplayName;

			// Use alien name as nicknames
			if (Unit1.IsAlien())
			{
				LocTag.NickName0 = Unit1.GetMyTemplate().strCharacterName;
				LocTag.LastName0 = LocTag.NickName0;
			}
			else
				LocTag.NickName0 = Unit1.GetNickName();

			if (LocTag.NickName0 == "''" || LocTag.NickName0 == "")
			{
				bExcludeNickNames = true;
			}

			// Use alien name as nicknames
			if (Unit2.IsAlien())
			{
				LocTag.NickName1 = Unit2.GetMyTemplate().strCharacterName;
				LocTag.LastName1 = LocTag.NickName1;
			}
			else
				LocTag.NickName1 = Unit2.GetNickName();

			if (LocTag.NickName1 == "''" || LocTag.NickName1 == "") //bsg-jneal (5.15.17): added missing second empty string check
			{
				bExcludeNickNames = true;
			}

			if (bExcludeNickNames)
			{
				for (i = 0; i < LinesStruct.ALines.Length; ++i)
				{
					if (InStr(LinesStruct.ALines[i], "NickName0") >= 0)
					{
						LinesStruct.ALines.Remove(i--, 1);
					}
				}
			}

			LocTag.RankName0 = `GET_RANK_STR(Unit1.GetRank(), Unit1.GetSoldierClassTemplateName());
			LocTag.RankName1 = `GET_RANK_STR(Unit2.GetRank(), Unit2.GetSoldierClassTemplateName());
			//LocTag.Flag = ;

			// If either unit is an alien, then allow them to use the duo lines
			if ((Unit1.IsAlien() || Unit2.IsAlien()) || (Unit1.kAppearance.iGender == Unit2.kAppearance.iGender))
			{
				if (Unit1.kAppearance.iGender == eGender_Male)
				{
					for (i = 0; i < Photobooth.m_arrDuoALines_Male.Length; ++i)
					{
						LinesStruct.ALines.AddItem(Photobooth.m_arrDuoALines_Male[i]);
					}
					for (i = 0; i < Photobooth.m_arrDuoBLines_Male.Length; ++i)
					{
						LinesStruct.BLines.AddItem(Photobooth.m_arrDuoBLines_Male[i]);
					}
				}
				else
				{
					for (i = 0; i < Photobooth.m_arrDuoALines_Female.Length; ++i)
					{
						LinesStruct.ALines.AddItem(Photobooth.m_arrDuoALines_Female[i]);
					}
					for (i = 0; i < Photobooth.m_arrDuoBLines_Female.Length; ++i)
					{
						LinesStruct.BLines.AddItem(Photobooth.m_arrDuoBLines_Female[i]);
					}
				}
			}
		}
		break;
	case ePBAT_SQUAD:
		LocTag.Kills = Photobooth.GetTotalKills();
		LocTag.Missions = Photobooth.GetTotalMissions();
		//LocTag.Flag = ;

		bCanChooseOperation = false;
		BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData', true));
		if (BattleData != none)
		{
			LocTag.Date = class'X2StrategyGameRulesetDataStructures'.static.GetDateString(BattleData.LocalTime);
			LocTag.Operation = BattleData.m_strOpName != "" ? BattleData.m_strOpName : "Operation [REDACTED]";
			bCanChooseOperation = true;
		}
		else if (`GAME.GetGeoscape() != none)
		{
			LocTag.Date = class'X2StrategyGameRulesetDataStructures'.static.GetDateString(`GAME.GetGeoscape().m_kDateTime);
		}

		MissionSite = XComGameState_MissionSite(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_MissionSite', true));
		if (MissionSite != none)
		{
			LocTag.Location = MissionSite.GetWorldRegion().GetMyTemplate().DisplayName;
		}

		LinesStruct.ALines = Photobooth.m_arrSquadALines;
		LinesStruct.BLines = Photobooth.m_arrSquadBLines;
		LinesStruct.OpLines = Photobooth.m_arrSquadOpLines;

		if (!bCanChooseOperation)
		{
			for (i = 0; i < LinesStruct.ALines.Length; ++i)
			{
				if (InStr(LinesStruct.ALines[i], "Operation") >= 0)
				{
					LinesStruct.ALines.Remove(i--, 1);
				}
			}

			for (i = 0; i < LinesStruct.BLines.Length; ++i)
			{
				if (InStr(LinesStruct.BLines[i], "Operation") >= 0)
				{
					LinesStruct.BLines.Remove(i--, 1);
				}
			}

			for (i = 0; i < LinesStruct.OpLines.Length; ++i)
			{
				if (InStr(LinesStruct.OpLines[i], "Operation") >= 0)
				{
					LinesStruct.OpLines.Remove(i--, 1);
				}
			}
		}

		if (LocTag.Location == "")
		{
			for (i = 0; i < LinesStruct.ALines.Length; ++i)
			{
				if (InStr(LinesStruct.ALines[i], "Location") >= 0)
				{
					LinesStruct.ALines.Remove(i--, 1);
				}
			}

			for (i = 0; i < LinesStruct.BLines.Length; ++i)
			{
				if (InStr(LinesStruct.BLines[i], "Location") >= 0)
				{
					LinesStruct.BLines.Remove(i--, 1);
				}
			}

			for (i = 0; i < LinesStruct.OpLines.Length; ++i)
			{
				if (InStr(LinesStruct.OpLines[i], "Location") >= 0)
				{
					LinesStruct.OpLines.Remove(i--, 1);
				}
			}
		}
		break;
	}

	LineChanceIndex = 0;
	if (bAutoGenDeadSoldier)
	{
		// Always use B line layout for dead soldiers
		LineChanceIndex = 1;
	}
	else
	{
		Roll = `SYNC_RAND_STATIC(100) - Photobooth.arrAutoTextChances[Usage].LineChances[LineChanceIndex];
		while (Roll >= 0)
		{
			Roll -= Photobooth.arrAutoTextChances[Usage].LineChances[++LineChanceIndex];
		}
	}

	bCapturedOnlyFonts = false;
	if (generatedTextLayoutState == ePBTLS_CapturedSoldier)
	{
		GeneratedText.AddItem(`XEXPAND.ExpandString(Photobooth.m_arrCapturedLines[`SYNC_RAND_STATIC(Photobooth.m_arrCapturedLines.Length)]));
		GeneratedText.AddItem(Photobooth.m_CapturedString);
		bCapturedOnlyFonts = true;
	}
	else if (!bAutoGenDeadSoldier && `SYNC_RAND_STATIC(100) < opLineChance)
	{
		Photobooth.SetTextLayoutByType(eTLT_TripleLine);
		switch (LineChanceIndex)
		{
		case 0:
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.ALines[`SYNC_RAND_STATIC(LinesStruct.ALines.Length)]));
			GeneratedText.AddItem("");
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.OpLines[`SYNC_RAND_STATIC(LinesStruct.OpLines.Length)]));
			break;
		case 1:
			GeneratedText.AddItem("");
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.BLines[`SYNC_RAND_STATIC(LinesStruct.BLines.Length)]));
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.OpLines[`SYNC_RAND_STATIC(LinesStruct.OpLines.Length)]));
			break;
		case 2:
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.ALines[`SYNC_RAND_STATIC(LinesStruct.ALines.Length)]));
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.BLines[`SYNC_RAND_STATIC(LinesStruct.BLines.Length)]));
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.OpLines[`SYNC_RAND_STATIC(LinesStruct.OpLines.Length)]));
			break;
		}
	}
	else
	{
		switch (LineChanceIndex)
		{
		case 0:
			Photobooth.SetTextLayoutByType(eTLT_SingleLine);
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.ALines[`SYNC_RAND_STATIC(LinesStruct.ALines.Length)]));
			break;
		case 1:
			Photobooth.SetTextLayoutByType(eTLT_SingleLine);
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.BLines[`SYNC_RAND_STATIC(LinesStruct.BLines.Length)]));
			break;
		case 2:
			Photobooth.SetTextLayoutByType(eTLT_DoubleLine);
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.ALines[`SYNC_RAND_STATIC(LinesStruct.ALines.Length)]));
			GeneratedText.AddItem(`XEXPAND.ExpandString(LinesStruct.BLines[`SYNC_RAND_STATIC(LinesStruct.BLines.Length)]));
			break;
		}
	}

	Photobooth.GetFonts(arrFontOptions, bCapturedOnlyFonts);
	if (defaultSettings.GeneratedText.length > 0 && bUseDefaultText)
	{
		GeneratedText = defaultSettings.GeneratedText;
		GeneratedFont = defaultSettings.FontNum;
		GeneratedFontColor = defaultSettings.FontColor;
		Photobooth.SetLayoutIndex(defaultSettings.TextLayoutNum);
	}
	else
	{
		for (i = 0; i < GeneratedText.Length; i++)
		{
			GeneratedFont.AddItem(`SYNC_RAND_STATIC(arrFontOptions.Length));
			GeneratedFontColor.AddItem(`SYNC_RAND_STATIC(Photobooth.m_RandomColors));
		}

		if (generatedTextLayoutState == ePBTLS_PromotedSoldier )
		{
			Photobooth.SetTextLayoutByType(eTLT_Promotion);
			GeneratedText[2] = Photobooth.m_PromotedString;
			GeneratedFont[2] = 0;
			GeneratedFontColor[2] = 2; // silver/grey index
		}

		defaultSettings.TextLayoutNum = Photobooth.m_currentTextLayoutTemplateIndex;
	}

	for (i = 0; i < Photobooth.m_PosterStrings.Length; ++i)
	{
		if (i < GeneratedText.Length)
		{
			Photobooth.SetTextBoxString(i, GeneratedText[i]);
			Photobooth.SetTextBoxFont(i, arrFontOptions[GeneratedFont[i]].FontName);
			Photobooth.SetTextBoxColor(i, GeneratedFontColor[i]);
		}
		else
		{
			Photobooth.SetTextBoxString(i, "");
		}
	}

	if (defaultSettings.GeneratedText.length == 0)
	{
		defaultSettings.GeneratedText = GeneratedText;
		defaultSettings.FontNum = GeneratedFont;
		defaultSettings.FontColor = GeneratedFontColor;
	}
}
