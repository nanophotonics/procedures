#pragma ModuleName = Lists
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

Function /S List(data, [separator, delimiter])
	Wave /T data
	String separator, delimiter

	If (ParamIsDefault(separator))
		separator = ":"
	EndIf
	If (ParamIsDefault(delimiter))
		delimiter = ";"
	EndIf

	Make /T /N=(DimSize(data, 0)) /FREE keys, values

	If (DimSize(data, 1) == 2)
		keys = data[p][0]
	EndIf

	values = data[p][DimSize(data, 1) - 1]

	Return SList(keys, values, separator=separator, delimiter=delimiter)
End

Function /S SList(keys, values, [separator, delimiter])
	Wave /T keys, values
	String separator, delimiter

	If (ParamIsDefault(separator))
		separator = ":"
	EndIf
	If (ParamIsDefault(delimiter))
		delimiter = ";"
	EndIf

	String list = ""
	Variable index, count
	For (index = 0, count = numpnts(values); index < count; index += 1)
		list += SelectString(strlen(keys[index]), "", keys[index] + separator) + values[index] + delimiter
	EndFor

	Return list
End

Function /S NList(keys, values, [separator, delimiter])
	Wave /T keys
	Wave values
	String separator, delimiter

	If (ParamIsDefault(separator))
		separator = ":"
	EndIf
	If (ParamIsDefault(delimiter))
		delimiter = ";"
	EndIf

	String list = ""
	Variable index, count
	For (index = 0, count = numpnts(values); index < count; index += 1)
		list += SelectString(strlen(keys[index]), "", keys[index] + separator) + num2str(values[index]) + delimiter
	EndFor

	Return list
End

Function /S ListSelect(list, expression, [delimiter])
	String list, expression, delimiter

	If (ParamIsDefault(delimiter))
		delimiter = ";"
	EndIf

	String result = ""

	String item
	Variable index, count
	For (index = 0, count = ItemsInList(list, delimiter); index < count; index += 1)
		item = StringFromList(index, list)
		If (GrepString(item, expression))
			result += item + delimiter
		EndIf
	EndFor

	Return result
End

Function /S ListReject(list, expression, [delimiter])
	String list, expression, delimiter

	If (ParamIsDefault(delimiter))
		delimiter = ";"
	EndIf

	String result = ""

	String item
	Variable index, count
	For (index = 0, count = ItemsInList(list, delimiter); index < count; index += 1)
		item = StringFromList(index, list)
		If (!GrepString(item, expression))
			result += item + delimiter
		EndIf
	EndFor

	Return result
End
