class X2Helpers_PhotoboothExtended extends Object;

static function string GetSoldierNameWithNick(int index)
{
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(`PHOTOBOOTH.m_arrUnits[index].UnitRef.ObjectID));

	return Unit.GetName(eNameType_FullNick);
}



static function int UNRRotationPercent(float Rotation)
{
	local int percent;

	percent = Rotation / class'PhotoboothExtendedSettings'.default.SoldierRotationMultiplier;
	if (percent < 0)
		percent = 100 + percent;
	
	return percent;
}

static function int DegreesToUNR(float Deg)
{
	return abs(Deg * DegToUnrRot);
}