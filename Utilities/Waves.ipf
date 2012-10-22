#pragma ModuleName = Waves
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

#include "Indices"

Static StrConstant DIMS = "xyzt"

Function Product(w)
	Wave w

	Variable index, p
	For (index = 0, p = 1; index < numpnts(w); index += 1)
		p *= w[index]
	EndFor

	Return p
End

Function SetScales(w, s, [inclusive, delta, all])
	Wave w, s
	Variable inclusive, delta, all

	If (ParamIsDefault(inclusive))
		inclusive = false
	EndIf
	If (ParamIsDefault(all))
		all = false
	EndIf

	Variable d
	If (all)
		For (d = 0; d < 4; d += 1)
			ScaleSet(w, d, s[0], s[1], inclusive=inclusive, delta=delta)
		EndFor
	Else
		For (d = 0; d < nx(s); d += 1)
			ScaleSet(w, d, s[d][0], s[d][1], inclusive=inclusive, delta=delta)
		EndFor
	EndIf
End

Static Function ScaleSet(w, d, a, b, [inclusive, delta])
	Wave w
	Variable d, a, b, inclusive, delta

	If (ParamIsDefault(inclusive))
		inclusive = false
	EndIf
	If (ParamIsDefault(delta))
		delta = false
	EndIf

	DF#Set(GetWavesDataFolderDFR(w))

	String command = "SetScale "
	If (inclusive)
		command += "/I "
	ElseIf (delta)
		command += "/P "
	EndIf
	command += DIMS[d] + ", %f, %f, "
	command += GetWavesDataFolder(w, 4)

	sprintf command, command, a, b

	Execute command

	DF#Pop()
End

Function Rescale(w, from, to)
	Wave w, from, to

	Make /FREE /N=(nx(from)) left, delta
	If (ny(from) == 0)
		delta = DimDelta(w, p)
	Else
		delta = DimDelta(w, p) * (to[p][1] - to[p][0])/(from[p][1] - from[p][0])
	EndIf

	left = to[p][0] - delta[p]/DimDelta(w, p) * (from[p][0] - DimLeft(w, p))

	Variable d
	For (d = 0; d < nx(delta); d += 1)
		ScaleSet(w, d, left[d], delta[d], delta=true)
	EndFor
End
