#pragma ModuleName = Maths
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

#include "Voigt"

Threadsafe Function deg(rad)
	Variable rad

	Return rad / pi * 180
End

Threadsafe Function rad(deg)
	Variable deg

	Return deg / 180 * pi
End

Constant RoundTo_Nearest = 0
Constant RoundTo_Down = 1
Constant RoundTo_Up = 2
Function RoundTo(value, step, [direction])
	Variable value
	Variable step
	Variable direction

	If (ParamIsDefault(direction))
		direction = RoundTo_Nearest
	EndIf

	value /= step

	Switch (direction)
	Case RoundTo_Nearest:
		value = round(value)
		Break

	Case RoundTo_Down:
		value = floor(value)
		Break

	Case RoundTo_Up:
		value = ceil(value)
		Break

	Default:
		Abort "Invalid direction passed to RoundTo"
	EndSwitch

	Return value * step
End

Threadsafe Function In(value, minimum, maximum)
	Variable value, minimum, maximum

	Return minimum <= value && value <= maximum
End

Threadsafe Function Clip(value, minimum, maximum)
	Variable value, minimum, maximum

	Return limit(value, minimum, maximum)
End

Threadsafe Function Restrict(value, minimum, maximum)
	Variable value, minimum, maximum

	Return In(value, minimum, maximum) ? value : NaN
End

Function Ellipticize(f, w, x, y, ratio, ph)
	FuncRef ProfilePrototype f
	Wave w
	Variable x, y, ratio, ph

	Return f(w, sqrt((x^2 + y^2) * (1 + (ratio - 1)^2 * cos(atan2(y, x) - ph)^2)))
End

Function ProfilePrototype(w, r)
	Wave w
	Variable r

	Abort "Invalid profile function"
End
