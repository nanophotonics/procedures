#pragma ModuleName = Serial
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

#include "Package"
#include "Utilities"

Static StrConstant this = "Serial"

Static Function New([port, delimiter, baud, databits, in, out, parity, stopbits, autoread, delay])
	String port, delimiter
	Variable baud, databits, in, out, parity, stopbits, autoread, delay

	If (ParamIsDefault(port))
		port = ""
	EndIf
	If (ParamIsDefault(baud))
		baud = 9600
	EndIf
	If (ParamIsDefault(databits))
		databits = 8
	EndIf
	If (ParamIsDefault(in))
		in = 0
	EndIf
	If (ParamIsDefault(out))
		out = 0
	EndIf
	If (ParamIsDefault(parity))
		parity = 0
	EndIf
	If (ParamIsDefault(stopbits))
		stopbits = 1
	EndIf
	If (ParamIsDefault(autoread))
		autoread = 1
	EndIf
	If (ParamIsDefault(delay))
		delay = 3
	EndIf
	If (ParamIsDefault(delimiter))
		delimiter = "\r"
	EndIf

	If (strlen(port) == 0)
		Prompt port, "Choose serial port:", popup, GetPorts()
		DoPrompt "Choose serial port", port
		If (V_Flag)
			Abort
		EndIf
	EndIf

	Delete(port=port)
	Package#New(this, path=port)

	SetActive(port, initialised=0)
	SetBaud(baud)
	SetDatabits(databits)
	SetIn(in)
	SetOut(out)
	SetParity(parity)
	SetStopbits(stopbits)
	SetAutoread(autoread)
	SetDelay(delay)
	SetDelimiter(delimiter)

	Initialise()
End

Static Function Initialise([port])
	String port

	If (ParamIsDefault(port))
		port = ""
	EndIf

	If (strlen(port) == 0)
		If (IsActive())
			port = GetActive()
		Else
			Abort "Could not initialise serial port. No active port found."
		EndIf
	EndIf

	If (!Package#Status(this, path=port))
		Abort "Could not initialise serial port. " + port + " data not found."
	EndIf

	If (!PortExists(port))
		Abort "Could not initialise serial port. " + port + " is not installed."
	EndIf

	SetActive(port, initialised=0)
	VDT2 /P=$port baud=GetBaud(), databits=GetDatabits(), in=GetIn(), out=GetOut(), parity=GetParity(), stopbits=GetStopbits(); AbortOnRTE
	VDTOpenPort2 $port; AbortOnRTE

	SetActive(port)
End

Static Function Delete([port])
	String port

	If (ParamIsDefault(port))
		port = GetActive()
	EndIf

	Package#Delete(this, path=port)
End

Static Function /S Read()
	String value = ""
	String chunk
	Variable length

	Do
		length = Pending()

		If (length == 0)
			Break
		EndIf

		VDTRead2 /T="\r" /O=3 /N=(length) chunk; AbortOnRTE

		value += chunk
	While (true)

	Return value
End

Static Function /S Write(command, [autoread, delay, delimiter])
	String command
	Variable autoread
	Variable delay
	String delimiter

	If (ParamIsDefault(autoread))
		autoread = GetAutoread()
	EndIf
	If (ParamIsDefault(delay))
		delay = GetDelay()
	EndIf
	If (ParamIsDefault(delimiter))
		delimiter = GetDelimiter()
	EndIf

	Read()
	VDTWrite2 /O=3 (command + delimiter); AbortOnRTE
	Sleep /Q /T delay

	If (autoread)
		Return Read()
	EndIf
End

Static Function PortExists(port)
	String port

	Return WhichListItem(port, GetPorts()) >= 0
End

Static Function /S GetPorts()
	VDTGetPortList2
	Return S_VDT
End

Static Function /S GetActive()
	Return Package#GetActive(this)
End

Static Function SetActive(port, [initialised])
	String port
	Variable initialised

	If (ParamIsDefault(initialised))
		initialised = 1
	EndIf

	Package#SetActive(this, port)

	If (initialised)
		VDTOperationsPort2 $port; AbortOnRTE
		KillStrings /Z S_VDT
	EndIf
End

Static Function GetBaud()
	NVar /SDFR=Active() baud
	Return baud
End

Static Function SetBaud(baud)
	Variable baud
	DFRef folder = Active()
	Variable /G folder:baud = baud
End

Static Function GetDatabits()
	NVar /SDFR=Active() databits
	Return databits
End

Static Function SetDatabits(databits)
	Variable databits
	DFRef folder = Active()
	Variable /G folder:databits = databits
End

Static Function GetIn()
	NVar /SDFR=Active() in
	Return in
End

Static Function SetIn(in)
	Variable in
	DFRef folder = Active()
	Variable /G folder:in = in
End


Static Function GetOut()
	NVar /SDFR=Active() out
	Return out
End

Static Function SetOut(out)
	Variable out
	DFRef folder = Active()
	Variable /G folder:out = out
End

Static Function GetParity()
	NVar /SDFR=Active() parity
	Return parity
End

Static Function SetParity(parity)
	Variable parity
	DFRef folder = Active()
	Variable /G folder:parity = parity
End


Static Function GetStopbits()
	NVar /SDFR=Active() stopbits
	Return stopbits
End

Static Function SetStopbits(stopbits)
	Variable stopbits
	DFRef folder = Active()
	Variable /G folder:stopbits = stopbits
End

Static Function GetAutoread()
	NVar /SDFR=Active() autoread
	Return autoread
End

Static Function SetAutoread(autoread)
	Variable autoread
	DFRef folder = Active()
	Variable /G folder:autoread = autoread
End

Static Function GetDelay()
	NVar /SDFR=Active() delay
	Return delay
End

Static Function SetDelay(delay)
	Variable delay

	DFRef folder = Active()
	Variable /G folder:delay = delay
End

Static Function /S GetDelimiter()
	SVar /SDFR=Active() delimiter
	Return delimiter
End

Static Function SetDelimiter(delimiter)
	String delimiter
	DFRef folder = Active()
	String /G folder:delimiter = delimiter
End

Static Function Pending()
	VDTGetStatus2 0, 0, 0; AbortOnRTE
	Return V_VDT
End

Static Function IsActive()
	Return Package#IsActive(this)
End

Static Function /DF Active()
	Return Package#ActiveFolder(this)
End
