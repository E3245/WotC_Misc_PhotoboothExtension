
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
