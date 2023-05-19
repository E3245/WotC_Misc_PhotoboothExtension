class Actor_PhotoboothProp extends Actor;

struct X2PhotoboothStaticMeshTemplate
{
	var name		TemplateName;
	var string		StaticMeshPath;
};

var StaticMeshComponent					CustomMesh;

var vector								ObjLocation;
var Rotator								ObjRotation;
var float								ObjScale;
var bool								bIsHidden;

var X2PhotoboothStaticMeshTemplate		TemplateInfo;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=PhotoboothMeshComponent
		HiddenGame=false
		bOwnerNoSee=false
		CastShadow=true
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		BlockRigidBody=false
		CollideActors=false
		bAcceptsDecals=true
		bAcceptsStaticDecals=true
		bAcceptsDynamicDecals=true
		bAcceptsLights=true
		//TranslucencySortPriority=1000
	End Object
	Components.Add(PhotoboothMeshComponent)
	CustomMesh=PhotoboothMeshComponent
}