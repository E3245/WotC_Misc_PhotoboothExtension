class PhotoboothDataStructures extends Object;

enum EUIPropagandaExtendedScreenType
{
	eUIPropagandaType_Base,
	eUIPropagandaType_Formation,
	eUIPropagandaType_SoldierData, 	// List of soldiers currently viewable in the scene
	eUIPropagandaType_Soldier,		// List of soldiers not in the scene but are avaliable
	eUIPropagandaType_SoldierEditor,
	eUIPropagandaType_SoldierBoneSelection,
	eUIPropagandaType_SoldierBoneEditor,
	eUIPropagandaType_Pose,
	eUIPropagandaType_Animations,
	eUIPropagandaType_BackgroundOptions,
	eUIPropagandaType_Background,
	eUIPropagandaType_Graphics,
	eUIPropagandaType_Fonts,
	eUIPropagandaType_TextColor,
	eUIPropagandaType_TextFont,
	eUIPropagandaType_Layout,
	eUIPropagandaType_Filter,
	eUIPropagandaType_Treatment,
	eUIPropagandaType_GradientColor1,
	eUIPropagandaType_GradientColor2,
	eUIPropagandaType_ObjectsList,
	eUIPropagandaType_ObjectEditor,
	eUIPropagandaType_PickObjectData,
	eUIPropagandaType_LightsList,
	eUIPropagandaType_LightEditor,
	eUIPropogandaType_EffectsList,
	eUIPropogandaType_EffectsEditor,
	eUIPropagandaType_ExtendedOptions,
	eUIPropagandaType_LandscapeMode,
	eUIPropagandaType_MAX
};

delegate vector NewObjectLocationCallback(); 