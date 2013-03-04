#pragma ModuleName = Utilities
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

#include "DF"
#include "Maths"
#include "Files"
#include "Strings"
#include "Waves"

Constant false = 0
Constant true = 1

Function Swap(a, b)
	Variable &a, &b
	Variable c = a
	a = b
	b = c
End

Function /S RTE([clear])
	Variable clear
	If (ParamIsDefault(clear))
		clear = false
	EndIf
	String message = GetRTErrMessage()
	clear = GetRTError(clear)
	Return message
End

Threadsafe Function IsNaN(x)
	Variable x
	Return NumType(x) == 2
End
