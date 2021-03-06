#pragma ModuleName = Waves
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

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
	
	Variable n = nx(from)

	Make /FREE /N=(n) left, delta, scale_delta
	delta = DimDelta(w, p)
	
	Switch (ny(from))
	Case 0:
	Case 1:
		scale_delta = 1
		Break
		
	Case 2:
		scale_delta = RescaleDelta(p, from, to)
		Break
		
	Default:
		Abort "Only need two points to uniquely define a scale!"
	EndSwitch

	left = to[p][0] - scale_delta[p] * (from[p][0] - DimLeft(w, p))
	delta *= scale_delta

	Variable i
	For (i = 0; i < n; i += 1)
		ScaleSet(w, i, left[i], delta[i], delta=true)
	EndFor
End

Static Function RescaleDelta(p, from, to)
	Variable p
	Wave from, to
	
	If (from[p][0] == from[p][1])
		Return 1
	EndIf
	
	Return (to[p][1] - to[p][0]) / (from[p][1] - from[p][0])
End

Function /WAVE ExtractIndex(data, dim, index)
	Wave data
	Variable dim, index
	
	If (index < 0)
		index += DimSize(data, dim)
	EndIf
	
	Make /FREE dims = {0, 1, 2}
	If (dim < 3)
		dims[dim,*] += 1
	EndIf
	
	Make /FREE /N=3 ns
	ns = DimSize(data, dims[p])
	If (ns[0] < 1)
		ns[0] = 1
	EndIf
	
	Make /FREE /N=(ns[0], ns[1], ns[2]) result
	SetScale /P x, DimOffset(data, dims[0]), DimDelta(data, dims[0]), result
	SetScale /P y, DimOffset(data, dims[1]), DimDelta(data, dims[1]), result
	SetScale /P z, DimOffset(data, dims[2]), DimDelta(data, dims[2]), result	

	Switch (dim)
	Case 0:
		Multithread result = data[index][p][q][r]
		Break
		
	Case 1:
		Multithread result = data[p][index][q][r]
		Break
		
	Case 2:
		Multithread result = data[p][q][index][r]
		Break
		
	Case 3:
		Multithread result = data[p][q][r][index]
		Break
	EndSwitch
	
	Return result
End