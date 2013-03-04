#pragma ModuleName = GUI
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

#include "Utilities"

Static StrConstant this = "GUI"

Static Function IgorStartOrNewHook(igor)
	String igor
	DefaultGUIFont all={"Segoe UI", 12, 0}
End

Function CenterWindow(win, [parent])
	String win
	String parent

	If (ParamIsDefault(parent))
		parent = ""
	EndIf

	If (strlen(parent) == 0)
		parent = "kwFrameInner"
	EndIf

	GetWindow $win, wsize

	Variable width = V_right - V_left
	Variable height = V_bottom - V_top

	GetWindow $parent, wsize

	MoveWindow /W=$win (V_left + V_right - width)/2, (V_top + V_bottom - height)/2, (V_left + V_right + width)/2, (V_top + V_bottom + height)/2
End

Function Hook(s)
	Struct WMWinHookStruct &s

	GetWindow $s.winName, activeSW

	FuncRef Hook parent = $(s.winName + "#" + s.eventName)
	FuncRef Hook child = $SelectString(cmpstr(s.winName, S_value), S_value + "_" + s.eventName, "")
	Return (!NumberByKey("ISPROTO", FuncRefInfo(child)) && child(s)) || (!NumberByKey("ISPROTO", FuncRefInfo(parent)) && parent(s))
End

Function ButtonControl(s) : ButtonControl
	Struct WMButtonAction &s

	String event = s.win + "#" + s.ctrlName + "_"

	Switch (s.eventCode)
	Case -1:
		event += "Kill"
		Break
	Case 1:
		event += "MouseDown"
		Break
	Case 2:
		event += "Click"
		Break
	Case 3:
		event += "MouseUp"
		Break
	Case 4:
		event += "MouseMove"
		Break
	Case 5:
		event += "MouseEnter"
		Break
	Case 6:
		event += "MouseLeave"
		Break
	EndSwitch

	FuncRef ButtonControl handler = $event
	Return !NumberByKey("ISPROTO", FuncRefInfo(handler)) && handler(s)
End

Function CheckBoxControl(s) : CheckBoxControl
	Struct WMCheckboxAction &s

	String event = s.win + "#" + s.ctrlName + "_"

	Switch (s.eventCode)
	Case -1:
		event += "Kill"
		Break
	Case 2:
		event += "Change"
		Break
	EndSwitch

	FuncRef CheckBoxControl handler = $event
	Return !NumberByKey("ISPROTO", FuncRefInfo(handler)) && handler(s)
End

Function ListBoxControl(s) : ListBoxControl
	Struct WMListBoxAction &s

	String event = s.win + "#" + s.ctrlName + "_"

	Switch (s.eventCode)
	Case -1:
		event += "Kill"
		Break
	Case 1:
		event += "MouseDown"
		Break
	Case 2:
		event += "Click"
		Break
	Case 3:
		event += "DoubleClick"
		Break
	Case 4:
	Case 5:
		event += "Select"
		Break
	Case 6:
		event += "BeginEdit"
		Break
	Case 7:
		event += "EndEdit"
		Break
	Case 8:
		event += "VScroll"
		Break
	Case 9:
		event += "HScroll"
		Break
	Case 10:
		event += "Scroll"
		Break
	Case 11:
		event += "ColumnResize"
		Break
	Case 12:
		event += "KeyPress"
		Break
	EndSwitch

	FuncRef ListBoxControl handler = $event
	Return !NumberByKey("ISPROTO", FuncRefInfo(handler)) && handler(s)
End

Function PopupMenuControl(s) : PopupMenuControl
	Struct WMPopupAction &s

	String event = s.win + "#" + s.ctrlName + "_"

	Switch (s.eventCode)
	Case -1:
		event += "Kill"
		Break
	Case 2:
		event += "Change"
		Break
	EndSwitch

	FuncRef PopupMenuControl handler = $event
	Return !NumberByKey("ISPROTO", FuncRefInfo(handler)) && handler(s)
End

Function RadioButtonControl(s) : CheckboxControl
	Struct WMCheckboxAction &s

	String event

	Switch (s.eventCode)
	Case -1:
		event = "Kill"
		Break
	Case 2:
		event = "Change"
		Break
	EndSwitch

	String group = StringFromList(0, s.ctrlName, "_")

	FuncRef RadioButtonControl handler = $("GUI#RadioButtonControl_" + event)
	If (!NumberByKey("ISPROTO", FuncRefInfo(handler)))
		handler(s)
	EndIf

	FuncRef RadioButtonControl handler = $(s.win + "#" + group + "_" + event)
	If (!NumberByKey("ISPROTO", FuncRefInfo(handler)))
		handler(s)
	EndIf

	FuncRef RadioButtonControl handler = $(s.win + "#" + s.ctrlName + "_" + event)
	Return !NumberByKey("ISPROTO", FuncRefInfo(handler)) && handler(s)
End

Static Function RadioButtonControl_Change(s)
	Struct WMCheckboxAction &s
	SetRadio(s.ctrlName, win=s.win)
End

Function SetRadio(name, [win])
	String name, win

	If (ParamIsDefault(win))
		win = ""
	EndIf

	String group = StringFromList(0, name, "_")
	String controls = ListSelect(ControlNameList(win), group + "_\\d+")

	String control
	Variable index, count = ItemsInList(controls)
	For (index = 0; index < count; index += 1)
		control = StringFromList(index, controls)
		CheckBox $control, value=!cmpstr(control, name), win=$win
	EndFor
End

Function SetVariableControl(s) : SetVariableControl
	Struct WMSetVariableAction &s

	String event = s.win + "#" + s.ctrlName + "_"

	Switch (s.eventCode)
	Case -1:
		event += "Kill"
		Break
	Case 1:
		event += "MouseUp"
		Break
	Case 2:
		event += "Change"
		Break
	Case 3:
		event += "Change"
		Break
	Case 4:
		event += "ScrollUp"
		Break
	Case 5:
		event += "ScrollDown"
		Break
	Case 6:
		event += "Update"
		Break
	EndSwitch

	FuncRef SetVariableControl handler = $event
	Return !NumberByKey("ISPROTO", FuncRefInfo(handler)) && handler(s)
End

Function SliderControl(s) : SliderControl
	Struct WMSliderAction &s

	String event = s.win + "#" + s.ctrlName + "_"

	Switch (s.eventCode)
	Case -1:
		event += "Kill"
		Break
	Case 9:
		event += "Change"
		Break
	EndSwitch

	FuncRef SliderControl handler = $event
	Return !NumberByKey("ISPROTO", FuncRefInfo(handler)) && handler(s)
End

Function /S Recreation(name)
	String name

	String code = WinRecreation(name, 0)

	code = ReplaceString(",", code, ", ")
	code = ReplaceString("= ", code, "=")

	Make /T /N=0 /FREE source
	PutScrapText code
	Grep /E="." "Clipboard" as source
	Make /T /N=0 /FREE destination, arguments

	String pattern = "(\\s*(?:Button|GroupBox|ListBox|SetVariable|TitleBox|ValDisplay) [^,]+)"

	String control
	String argument

	Variable index = 0

	Variable line, count
	For (line = 0, count = numpnts(source); line < count; line += 1)
		SplitString /E=(pattern + ",\\s*(.*)") source[line], control, argument
		If (V_flag)
			FindValue /TEXT=(control) /TXOP=4 destination
			If (V_value > -1)
				arguments[V_Value] += "," + argument
				V_flag = false
			EndIf
		Else
			control = source[line]
			argument = ""
			V_flag = true
		EndIf

		If (V_flag)
			InsertPoints index, 1, destination, arguments
			destination[index] = control
			arguments[index] = argument
			index += 1
		EndIf
	EndFor

	For (line = 0; line < index; line += 1)
		If (strlen(arguments[line]))
			destination[line] += ", " + SortArguments(arguments[line])
		EndIf
	EndFor

	code = Join(destination, delimiter="\r")
	code = ReplaceString("\tGroupBox", code, "\r\tGroupBox")
	PutScrapText code
	Return code
End

Static Function /S SortArguments(arguments)
	String arguments

	Wave /T args = Split(arguments, ",\\s*(?=" + Regex_Name + "=)")
	Make /N=(numpnts(args)) /FREE keys

	keys = SortKey(StringFromList(0, args[p], "="))
	Sort keys, args

	Return Join(args, delimiter=", ")
End

Static Function SortKey(keyword)
	String keyword

	Return WhichListItem(keyword, "pos;size;bodyWidth;fixedSize;anchor;widths;userColumnResize;title;picture;value;listWave;selWave;colorWave;mode;format;limits;disable;noedit;frame;font;fSize;fStyle;fColor;labelBack;valueColor;valueBackColor;help;proc")
End

Function BrowseLayers(s) : SetVariableControl
	Struct WMSetVariableAction &s

	Switch (s.eventCode)
	Case 1:
	Case 2:
	Case 3:
		ModifyImage /W=$s.win ''#0, plane=s.dval
		Break
	EndSwitch

	Return 0
End

Function AddLayerBrowser()
	SetVariable layer pos={20,20},proc=BrowseLayers,value= _NUM:0,limits={0,inf,1}
End

Function HitGraph(graph, h, v, [x, y])
	String graph
	Variable h, v, &x, &y

	String axis, axes = AxisList(graph)
	Variable index, count = ItemsInList(axes)

	Variable hit = true, horizontal = false, vertical = false

	For (index = 0; index < count && !(horizontal && vertical); index += 1)
		axis = StringFromList(index, axes)

		StrSwitch (StringByKey("AXTYPE", AxisInfo(graph, axis)))
		Case "top":
		Case "bottom":
			If (!horizontal)
				horizontal = true

				h = AxisValFromPixel(graph, axis, h)
				GetAxis /Q /W=$graph $axis
				hit = hit && in(h, v_min, v_max)

				If (!ParamIsDefault(x))
					x = h
				EndIf
			EndIf
			Break

		Case "left":
		Case "right":
			If (!vertical)
				vertical = true

				v = AxisValFromPixel(graph, axis, v)
				GetAxis /Q /W=$graph $axis
				hit = hit && in(v, v_min, v_max)

				If (!ParamIsDefault(y))
					y = v
				EndIf
			EndIf
			Break
		EndSwitch
	EndFor

	Return hit
End

Function /S HitAnyGraph(graphs, h, v, [x, y])
	String graphs
	Variable h, v, &x, &y

	Variable dummy
	If (ParamIsDefault(x))
		If (ParamIsDefault(y))
			Return HitAnyGraph(graphs, h, v, x=dummy, y=dummy)
		Else
			Return HitAnyGraph(graphs, h, v, x=dummy, y=y)
		EndIf
	ElseIf (ParamIsDefault(y))
		Return HitAnyGraph(graphs, h, v, x=x, y=dummy)
	EndIf

	String graph
	Variable index, count = ItemsInList(graphs)

	For (index = 0; index < count; index += 1)
		graph = StringFromList(index, graphs)

		If (HitGraph(graph, h, v, x=x, y=y))
			Return graph
		EndIf
	EndFor

	Return ""
End
