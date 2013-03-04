#pragma ModuleName = Logger
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

#include "Package"

Static StrConstant this = "Logger"

Static Function New([name, function, parameter, path, interval])
	String name, function, parameter, path
	Variable interval

	String function_

	If (ParamIsDefault(name))
		name = ""
	EndIf
	If (ParamIsDefault(function))
		function_ = ""
	Else
		function_ = function
	EndIf
	If (ParamIsDefault(parameter))
		parameter = ""
	EndIf
	If (ParamIsDefault(interval))
		interval = 1
	EndIf
	If (ParamIsDefault(path))
		PathInfo home
		If (strlen(S_Path) == 0)
			path = ""
		Else
			path = S_Path + "Logs"
		EndIf
	EndIf

	If (strlen(name) == 0)
		name = "Default"
	EndIf
	If (strlen(function_) == 0)
		Prompt function_, "Enter logging function for " + name + ":"
		DoPrompt "Choose logging function", function_
		If (V_Flag)
			Abort
		EndIf
	EndIf
	If (strlen(path) == 0)
		Prompt path, "Enter log folder path:"
		DoPrompt "Choose log folder", path
		If (V_Flag)
			Abort
		EndIf
	EndIf

	Delete(name=name)
	Package#New(this, path=name)

	SetActive(name)
	SetFunction(function_)
	SetParameter(parameter)
	SetInterval(interval)
	SetPath(path)

	MakeVariables()

	Initialise()
End


Static Function Initialise([name])
	String name

	If (ParamIsDefault(name))
		name = ""
	EndIf

	If (strlen(name) == 0)
		If (IsActive())
			name = GetActive()
		Else
			Abort "Could not initialise logger. No active log found."
		EndIf
	EndIf

	If (!Package#Status(this, path=name))
		Abort "Could not initialise logger. " + name + " data not found."
	EndIf

	SetActive(name)

	InitialiseTask()
End


Static Function Delete([name])
	String name

	If (ParamIsDefault(name))
		name = GetActive()
	EndIf

	If (Package#Status(this, path=name))
		String active = ""
		If (CmpStr(name, GetActive()) != 0)
			active = GetActive()
			SetActive(name)
		EndIf
		Stop()
		SetActive(active)
	EndIf

	Package#Delete(this, path=name)
End


Static Function Start()
	String name = GetActive()

	If (!GetRunning())
		SetFile(num2istr(DateTime))
		String filename = GetPath() + name + "." + GetFile() + ".log"

		MakeFIFO()

		Variable file
		Open file as filename
		CtrlFIFO $name, file=file, size=1, start
	EndIf
	If (GetPaused())
		CtrlNamedBackground $name, start
	EndIf
End


Static Function Stop()
	If (GetRunning())
		String name = GetActive()
		CtrlNamedBackground $name, stop
		CtrlFIFO $name, stop
		KillFIFO $name
	EndIf
End


Static Function Pause()
	CtrlNamedBackground $GetActive(), stop
End


Function /DF Load([history, folder])
	Variable history
	DFRef folder

	If (ParamIsDefault(history))
		history = 0
	EndIf
	If (ParamIsDefault(folder))
		folder = Active()
		NewDataFolder /O folder:Data
		folder = folder:Data
	EndIf

	history = DateTime - history * 24 * 60 * 60

	String name = GetActive()

	NewPath /O /Q logger_load GetPath()

	String directory = SortList(ListMatch(IndexedFile(logger_load, -1, ".log"), name + ".*.log"), ";", 1)
	String files = ""

	Variable index, count
	String item

	For (index = 0, count = ItemsInList(directory); index < count; index += 1)
		item = StringFromList(index, directory)
		If (index == 0 || str2num(StringFromList(1, item, ".")) > history)
			files += item + ";"
		Else
			Break
		EndIf
	EndFor

	String variables = GetVariables()
	For (index = 0, count = ItemsInList(variables, ","); index < count; index += 1)
		item = StringFromList(index, variables, ",")

		Make /O /N=0 folder:$item
	EndFor

	String waves = GetWaves()
	For (index = 0, count = ItemsInList(waves, ","); index < count; index += 1)
		item = StringFromList(index, waves, ",")

		Make /O /Y=(NumberByKey("Type", item)) /N=(0, NumberByKey("Length", item)) folder:$(StringByKey("Name", item))
		WAVE data = folder:$(StringByKey("Name", item))
		SetScale d, 0, 0, StringByKey("Units", item), data
	EndFor

	Make /I /U /O /N=0 folder:clock
	WAVE clock = folder:clock
	SetScale d, 0, 0, "dat", clock

	For (index = ItemsInList(files) - 1; index >= 0; index -= 1)
		LoadFIFO(StringFromList(index, files), folder)
	EndFor

	Return folder
End


Static Function MakeVariables()
	DFRef previous = GetDataFolderDFR()

	SetDataFolder Measure()

	SetVariables(VariableList("*", ",", 4))
//	SetStrings(StringList("*", ","))

	String waves = ""
	String names = WaveList("*", ",", "")

	Variable index, count
	String item

	For (index = 0, count = ItemsInList(names, ","); index < count; index += 1)
		item = StringFromList(index, names, ",")
		waves += "Name:" + item + ";" + "Units:" + WaveUnits($item, -1) + ";" + "Length:" + num2istr(numpnts($item)) + ";" + "Type:" + num2istr(WaveType($item)) + ";" + ","
	EndFor

	SetWaves(waves)
	SetChannels(FIFOChannels(GetVariables(), "num") + FIFOChannels(names, "vect") + ",num=DateTime")

	SetDataFolder previous
End


Static Function InitialiseTask()
	CtrlNamedBackground $GetActive(), period=GetInterval()*60*60, proc=Logger#Push
End


Static Function MakeFIFO([name])
	String name

	If (ParamIsDefault(name))
		name = ""
	EndIf

	If (strlen(name) == 0)
		name = GetActive()
	EndIf

	NewFIFO $name

	String variables = GetVariables()
	String waves = GetWaves()

	Variable index, count
	String item

	For (index = 0, count = ItemsInList(variables, ","); index < count; index += 1)
		item = StringFromList(index, variables, ",")
		NewFIFOChan $name, $item, 0, 1, 0, 0, ""
	EndFor

	For (index = 0, count = ItemsInList(waves, ","); index < count; index += 1)
		item = StringFromList(index, waves, ",")
		NewFIFOChan $name, $(StringByKey("Name", item)), 0, 1, 0, 0, StringByKey("Units", item), NumberByKey("Length", item)
	EndFor

	NewFIFOChan /I /U $name, clock, 0, 1, 0, 0, "dat"
End


Static Function LoadFIFO(filename, folder)
	String filename
	DFRef folder

	Print "Loading " + filename

	MakeFIFO(name="logger_load")

	Variable file
	Open /R /P=logger_load file as filename
	CtrlFIFO logger_load, rfile=file

	FIFOStatus /Q logger_load
	Variable points = V_FIFOChunks

	Variable index, count
	String item

	String variables = GetVariables()
	For (index = 0, count = ItemsInList(variables, ","); index < count; index += 1)
		item = StringFromList(index, variables, ",")
		LoadChannel(item, folder, points)
	EndFor

	String waves = GetWaves()
	For (index = 0, count = ItemsInList(waves, ","); index < count; index += 1)
		item = StringFromList(index, waves, ",")
		LoadChannel(StringByKey("Name", item), folder, points)
	EndFor

	LoadChannel("clock", folder, points)

	WAVE clock = folder:clock
	clock[numpnts(clock) - 1] = clock[numpnts(clock) - 2] + 1

	KillFIFO logger_load
End


Static Function LoadChannel(name, folder, points)
	String name
	DFRef folder
	Variable points

	WAVE data = folder:$name
	Variable rows = DimSize(data, 0)
	Variable cols = DimSize(data, 1)
	Variable type = WaveType(data)

	Redimension /Y=(type) /N=(rows + points + 1, cols) data

	Make /FREE /Y=(type) /N=(points, cols) contents
	FIFO2Wave logger_load, $name, contents

	If (cols > 0)
		MatrixTranspose contents
	EndIf

	data[rows,][] = contents[p - rows][q]
	data[rows + points][] = NaN
End


Static Function Push(info)
	STRUCT WMBackgroundStruct &info

	Variable error = 0
	DFRef previous = GetDataFolderDFR()

	SetActive(info.name)

	Try
		SetDataFolder Measure(); AbortOnRTE
		Execute "AddFIFOVectData " + info.name + GetChannels()
	Catch
		error = 1
	EndTry

	SetDataFolder previous
	Return error
End


Static Function /DF Measure()
	String parameter = GetParameter()
	DFRef folder = NewFreeDataFolder()

	If (strlen(parameter) > 0)
		FuncRef LoggerMeasureParamPrototype fp = $GetFunction()
		fp(parameter, folder)
	Else
		FuncRef LoggerMeasurePrototype f = $GetFunction()
		f(folder)
	EndIf

	Return folder
End


Function LoggerMeasurePrototype(folder)
	DFRef folder

	Abort "Invalid logging function."
End

Function LoggerMeasureParamPrototype(parameter, folder)
	String parameter
	DFRef folder

	Abort "Invalid logging function."
End


Static Function /S FIFOChannels(list, type)
	String list
	String type

	Return ReplaceString(",", RemoveEnding("," + list, ","), "," + type + "=")
End


Static Function GetRunning()
	FIFOStatus /Q $GetActive()
	Return V_FIFORunning
End


Static Function GetPaused()
	CtrlNamedBackground $GetActive(), status
	Return GetRunning() && !NumberByKey("Run", S_Info)
End


Static Function /S GetActive()
	Return Package#GetActive(this)
End
Static Function SetActive(name)
	String name
	Package#SetActive(this, name)
End


Static Function /S GetFunction()
	SVar /SDFR=Active() function
	Return function
End
Static Function SetFunction(function)
	String function
	DFRef folder = Active()
	String /G folder:function = function
End


Static Function /S GetParameter()
	SVar /SDFR=Active() parameter
	Return parameter
End
Static Function SetParameter(parameter)
	String parameter
	DFRef folder = Active()
	String /G folder:parameter = parameter
End


Static Function GetInterval()
	NVar /SDFR=Active() interval
	Return interval
End
Static Function SetInterval(interval)
	Variable interval
	DFRef folder = Active()
	Variable /G folder:interval = interval
End


Static Function /S GetPath()
	SVar /SDFR=Active() path
	Return path
End
Static Function SetPath(path)
	String path
	DFRef folder = Active()
	path = RemoveEnding(path, ":") + ":"
	NewPath /O /Q /C logger_unused, path
	String /G folder:path = path
End


Static Function /S GetFile()
	SVar /SDFR=Active() file
	Return file
End
Static Function SetFile(file)
	String file
	DFRef folder = Active()
	String /G folder:file = file
End


Static Function /S GetVariables()
	SVar /SDFR=Active() variables
	Return variables
End
Static Function SetVariables(variables)
	String variables
	DFRef folder = Active()
	String /G folder:variables = variables
End


//Static Function /S GetStrings()
//	SVar /SDFR=Active() strings
//	Return strings
//End
//Static Function SetStrings(strings)
//	String strings
//	DFRef folder = Active()
//	String /G folder:strings = strings
//End


Static Function /S GetWaves()
	SVar /SDFR=Active() waves
	Return waves
End
Static Function SetWaves(waves)
	String waves
	DFRef folder = Active()
	String /G folder:waves = waves
End


Static Function /S GetChannels()
	SVar /SDFR=Active() channels
	Return channels
End
Static Function SetChannels(channels)
	String channels
	DFRef folder = Active()
	String /G folder:channels = channels
End


Static Function IsActive()
	Return Package#IsActive(this)
End


Static Function /DF Active()
	Return Package#ActiveFolder(this)
End


//Static Function Transfer()
//
//	GetFileFolderInfo /Q /Z GetFilename(extension="fifo")
//	If (V_Flag)
//		MakeFIFO()
//		StartFIFO()
//	Else
//		DFRef previous = GetDataFolderDFR()
//		SetDataFolder Data()
//		NewDataFolder w
//
//		String fifo = GetName()
//
//		Variable points
//		Load(folder=folder, points=points)
//
//		String variables = GetVariables()
//		String waves = GetWaves()
//
//		String channels = "AddFIFOVectData " + fifo + ","
//
//		Variable index, count
//		String item
//
//		For (index = 0, count = ItemsInList(variables, ","); index < count; index += 1)
//			item = StringFromList(index, variables, ",")
//
//			channels += "num=" + item + "[%],"
//		EndFor
//
//		For (index = 0, count = ItemsInList(waves, ","); index < count; index += 1)
//			item = StringByKey("Name", StringFromList(index, waves, ","))
//
//			channels += "vect=:w:" + item + ","
//		EndFor
//
//		channels += "num=clock[%]"
//
//		MakeFIFO()
//		StartFIFO()
//
//		Variable waveindex
//
//		For (index = 0; index < points; index += 1)
//			For (waveindex = 0, count = ItemsInList(waves, ","); waveindex < count; waveindex += 1)
//				item = StringByKey("Name", StringFromList(waveindex, waves, ","))
//				Duplicate /O /R=[index] $item, :w:$item
//			EndFor
//
//			Execute ReplaceString("%", channels, num2istr(index))
//		EndFor
//
//		KillDataFolder /Z w
//		SetDataFolder previous
//	EndIf
//End
