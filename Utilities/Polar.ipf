#pragma ModuleName = Polar
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

Threadsafe Function rph2x(r, ph)
	Variable r, ph
	Return r * cos(ph)
End

Threadsafe Function rph2y(r, ph)
	Variable r, ph
	Return r * sin(ph)
End

Threadsafe Function xy2r(x, y)
	Variable x, y
	Return sqrt(x^2 + y^2)
End

Threadsafe Function xy2ph(x, y)
	Variable x, y
	Return atan2(y, x)
End
