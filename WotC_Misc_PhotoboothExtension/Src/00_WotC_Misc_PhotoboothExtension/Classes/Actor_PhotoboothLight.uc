class Actor_PhotoboothLight extends Actor;

var SpotLightComponent					SpotLight;
var PointLightComponent					PointLight;
//var LightComponent					Light;

var	StaticMeshComponent					MeshIcon;

enum ePhotoboothLightType
{
	ePBLight_Spot,
	ePBLight_Point,
	ePBLight_MAX
};

var ePhotoboothLightType				eActiveLightType;
var vector								ObjLocation;
var Rotator								ObjRotation;
var float								ObjBrightness;
var bool								bIsEnabled;
var bool								bHelperMeshHidden;

var string								objColorHexStr;

var localized string					strLightType_Spot;
var localized string					strLightType_Point;

event PostBeginPlay()
{
	local StaticMesh NewMesh;
	local RenderChannelContainer RenderChannels;

	RenderChannels.MainScene = true;
	RenderChannels.SecondaryScene = true;

	super.PostBeginPlay();

	// Spawn Axis mesh and set to static mesh
	NewMesh = StaticMesh(DynamicLoadObject("WotC_PhotoboothPlusPackage.Axis_Display_Photobooth", class'StaticMesh', true));
	MeshIcon.SetStaticMesh(NewMesh);
	MeshIcon.SetAbsolute(true,true,true);
	MeshIcon.SetRenderChannels(RenderChannels);	// So the Axis mesh can be shown even with BG Post Processing active
	bHelperMeshHidden = false;
}

function SetLightPosition(Vector newPos)
{
	SpotLight.SetTranslation(newPos);
	PointLight.SetTranslation(newPos);

	MeshIcon.SetTranslation(newPos);
	ObjLocation = newPos;
}

function SetLightRotation(Rotator newRot)
{
	SpotLight.SetRotation(newRot);

	MeshIcon.SetRotation(newRot);

	ObjRotation = newRot;
}

function string GetLightDescription()
{
	switch(eActiveLightType)
	{
		case ePBLight_Spot:
			return strLightType_Spot;
		case ePBLight_Point:
			return strLightType_Point;
	}
}

function NextLight()
{
	eActiveLightType = ePhotoboothLightType((eActiveLightType + 1) % ePBLight_MAX);

	OnSwapActiveLight();
}

function PreviousLight()
{
	eActiveLightType = ePhotoboothLightType((eActiveLightType - 1) % ePBLight_MAX);

	OnSwapActiveLight();
}

private function OnSwapActiveLight()
{
	SpotLight.SetEnabled(false);
	PointLight.SetEnabled(false);

	switch (eActiveLightType)
	{
		case ePBLight_Spot:
			SpotLight.SetEnabled(bIsEnabled);
			break;
		case ePBLight_Point:
			PointLight.SetEnabled(bIsEnabled);
			break;
	}
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=LightMeshComponent
		HiddenGame=false
		bOwnerNoSee=false
		CastShadow=false
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		BlockRigidBody=false
		CollideActors=false
		bAcceptsDecals=false
		bAcceptsStaticDecals=false
		bAcceptsDynamicDecals=false
		bAcceptsLights=false
		//TranslucencySortPriority=1000
	End Object
	Components.Add(LightMeshComponent)
	MeshIcon=LightMeshComponent

	Begin Object Class=SpotLightComponent Name=SpotLightComponentObject
		CastShadows				= true;
		CastStaticShadows		= true;
		CastDynamicShadows		= true;
		bAbsoluteTranslation=true
		MinRoughness=1.0
		bEnabled=false
		Brightness=10.0
		LightColor = (R = 255,G = 255,B = 255)		
		bRemoveWithDestruction	= true;
	End Object
	SpotLight=SpotLightComponentObject
	Components.Add(SpotLightComponentObject)

	Begin Object Class=PointLightComponent Name=PointLightComponentObject
		CastShadows				= true;
		CastStaticShadows		= true;
		CastDynamicShadows		= true;
		bAbsoluteTranslation=true
		MinRoughness=1.0
		bEnabled=false
		Brightness=10.0
		LightColor = (R = 255,G = 255,B = 255)		
		bRemoveWithDestruction	= true;
	End Object
	PointLight=PointLightComponentObject
	Components.Add(PointLightComponentObject)
}