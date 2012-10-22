#pragma IndependentModule = Shutter
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

#include "Package"
#include "Serial"
#include "Utilities"

Static StrConstant this = "Shutter"

Function New([port])
	String port

	If (ParamIsDefault(port))
		Prompt port, "Choose Shutter control serial port:", popup, Serial#GetPorts()
		DoPrompt "Locate shutter", port
		If (V_Flag)
			Abort
		EndIf
	EndIf

	Delete(port=port)
	Package#New(this, path=port)

	SetActive(port)

	Serial#New(port=port)

	Initialise()
End

Function Initialise([port])
	String port

	If (ParamIsDefault(port))
		port=""
	EndIf

	If (strlen(port) == 0)
		If (IsActive())
			port = GetActive()
		Else
			Abort "Could not initialise SC10. No active shutter found."
		EndIf
	EndIf

	If (!Package#Status(this, path=port))
		Abort "Could not initialise SC10. " + port + " data not found."
	EndIf

	SetActive(port)

	Serial#Initialise(port=port)
End

Function Delete([port])
	String port

	If (ParamIsDefault(port))
		port = GetActive()
	EndIf

	Serial#Delete(port=port)

	Package#Delete(this, path=port)
End

Function Toggle()
	Write("ens")
End

Function Set(open_)
	Variable open_
	If (open_ != GetOpen())
		Toggle()
	EndIf
End

Function /S GetActive()
	Return Package#GetActive(this)
End

Function SetActive(port)
	String port

	Package#SetActive(this, port)
End

Function GetOpen()
	Variable open_
	sscanf Write("ens?"), "ens?%f", open_
	Return open_
End

Function SetOpen(open_)
	Variable open_
	Set(open_)
End

Function GetShut()
	Return !GetOpen()
End

Function SetShut(shut)
	Variable shut
	Set(!shut)
End

Function GetOpenTime()
	Variable openTime
	sscanf Write("open?"), "open?%f", openTime
	Return openTime
End

Function SetOpenTime(openTime)
	Variable openTime
	Write("open=" + num2istr(openTime))
End

Function GetShutTime()
	Variable shutTime
	sscanf Write("shut?"), "shut?%f", shutTime
	Return shutTime
End

Function SetShutTime(shutTime)
	Variable shutTime
	Write("shut=" + num2istr(shutTime))
End

Static Function /S Write(command)
	String command

	Serial#SetActive(GetActive())
	Return Serial#Write(command)
End

Static Function IsActive()
	Return Package#IsActive(this)
End

Static Function /DF Active()
	Return Package#ActiveFolder(this)
End
