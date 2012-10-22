#pragma ModuleName = Strings
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

#include "Lists"

StrConstant Regex_Name = "[a-zA-Z]\\w*"

Function /S Quote(name, [with, before, after])
	String name
	String with
	String before
	String after

	If (ParamIsDefault(with))
		If (ParamIsDefault(before))
			before = "'"
		EndIf
		If (ParamIsDefault(after))
			after = before
		EndIf
	Else
		before = with
	EndIf

	Return before + name + after
End

Function /S Join(text, [delimiter])
	Wave /T text
	String delimiter

	If (ParamIsDefault(delimiter))
		delimiter = ","
	EndIf

	String result = ""
	Variable index, count
	For (index = 0, count = numpnts(text); index < count - 1; index += 1)
		result += text[index] + delimiter
	EndFor

	Return result + text[index]
End

Function /WAVE Split(text, expression)
	String text
	String expression

	Make /T /N=1 /FREE matches

	String before
	String after
	Do
		SplitString /E=("(.*)" + expression + "(.*)") text, before, after
		If (strlen(after))
			InsertPoints 1, 1, matches
			matches[1] = after
		EndIf
		If (strlen(before))
			text = before
		EndIf
	While (V_flag > 1)
	matches[0] = text

	Return matches
End

Function /S PadLeft(text, length, [pad])
	String text
	Variable length
	String pad

	If (ParamIsDefault(pad))
		pad = " "
	EndIf

	Return PadString("", length - strlen(text), char2num(pad)) + text
End

Function /S PadRight(text, length, [pad])
	String text
	Variable length
	String pad

	If (ParamIsDefault(pad))
		pad = " "
	EndIf

	Return PadString("", length - strlen(text), char2num(pad)) + text
End

Function /S ZeroPad(number, length)
	Variable number
	Variable length

	Return PadLeft(num2str(number), length, pad="0")
End
