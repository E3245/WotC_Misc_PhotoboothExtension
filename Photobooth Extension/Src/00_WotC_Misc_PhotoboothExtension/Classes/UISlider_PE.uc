class UISlider_PE extends UISlider;

/*
var float			fSlideIdleTime;
var float			fSlideIdleMaxTime;

var bool			bMouseDown;

simulated event Tick(float DT)
{
	if (bMouseDown)
	{
		fSlideIdleTime -= dt;
	}
	else
	{
		fSlideIdleTime = fSlideIdleMaxTime;
	}

	if (fSlideIdleTime < 0)
	{
		fSlideIdleTime = fSlideIdleMaxTime;
		bMouseDown = false;
	}
}

simulated function OnMouseEvent(int cmd, array<string> args)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_DOWN && !bIsDisabled)
	{
		bMouseDown = true;
	}

	// send a clicked callback
	if(cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP && !bIsDisabled)
	{
		if( float(args[args.length-1]) == INCREASE_VALUE )
			OnIncrease();
		else if( float(args[args.length-1]) == DECREASE_VALUE )
			OnDecrease();
		else
			SetPercent( float(args[args.length-1]) ); 

		if( onChangedDelegate != none)
			onChangedDelegate(self);
	}
}

defaultproperties
{
	fButtonHoldMaxTime = 0.8f
	bMouseDown = false
}
*/