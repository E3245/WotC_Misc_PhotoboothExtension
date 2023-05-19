class Actor_PhotoboothFX extends Actor;

struct X2PhotoboothFXTemplate
{
	var name		TemplateName;
	var string		ParticleSystemPath;
};

var XComEmitter							Emitter;
var	StaticMeshComponent					MeshIcon;

var vector								ObjLocation;
var Rotator								ObjRotation;
var bool								bIsEnabled;
var bool								bHelperMeshHidden;

var X2PhotoboothFXTemplate				TemplateInfo;

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

function CreateNewParticle(X2PhotoboothFXTemplate TemplateInfo)
{
	if (Emitter != none)
		KillParticle();

	Emitter = Spawn(class'XComEmitter', self);
	Emitter.SetTemplate(ParticleSystem(DynamicLoadObject(TemplateInfo.ParticleSystemPath, class'ParticleSystem')));
	Emitter.LifeSpan = 60 * 60 * 24 * 7; // never die (or at least take a week to do so)
}

function SetEmitterPosition(Vector newPos)
{
	MeshIcon.SetTranslation(newPos);
	ObjLocation = newPos;
}

function SetEmitterRotation(Rotator newRot)
{
	MeshIcon.SetRotation(newRot);
	ObjRotation = newRot;
}

function KillParticle()
{
	Emitter.Destroy();
}