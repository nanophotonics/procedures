#pragma IndependentModule = VariSpec
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

#include "Package"
#include "Serial"

Static StrConstant this = "VariSpec"

Function New([port])
	String port

	If (ParamIsDefault(port))
		Prompt port, "Choose VariSpec control serial port:", popup, Serial#GetPorts()
		DoPrompt "Locate filter", port
		If (V_Flag)
			Abort
		EndIf
	EndIf

	Delete(port=port)
	Package#New(this, path=port)

	SetActive(port)

	Serial#New(port=port, in=2, out=2)

	Initialise()
End

Function Initialise([port, force])
	String port
	Variable force

	If (ParamIsDefault(port))
		port = ""
	EndIf
	If (ParamIsDefault(force))
		force = 0
	EndIf

	If (strlen(port) == 0)
		If (IsActive())
			port = GetActive()
		Else
			Abort "Could not initialise VariSpec. No active filter found."
		EndIf
	EndIf

	If (!Package#Status(this, path=port))
		Abort "Could not initialise VariSpec. " + port + " data not found."
	EndIf

	SetActive(port)

	Serial#Initialise(port=port)

	Write("B 1")

	If (force || !GetInitialised())
		Write("I 1")
	EndIf
End

Function Delete([port])
	String port

	If (ParamIsDefault(port))
		port = GetActive()
	EndIf

	Serial#Delete(port=port)

	Package#Delete(this, path=port)
End

Function Exercise([cycles])
	Variable cycles

	If (ParamIsDefault(cycles))
		cycles = 3
	EndIf

	Write("E " + num2istr(cycles))
End

Function /S GetActive()
	Return Package#GetActive(this)
End

Function SetActive(port)
	String port
	Package#SetActive(this, port)
End

Function GetWavelength()
	Variable wavelength
	sscanf Write("W?"), "W?%f", wavelength
	Return wavelength
End

Function SetWavelength(wavelength)
	Variable wavelength
	Write("W " + num2istr(wavelength))
End

Function GetAlarm()
	Variable alarm
	sscanf Write("R?"), "R?%d", alarm
	Return alarm
End

Function ClearAlarm()
	Write("R 1")
End

Function GetInitialised()
	Variable initialised
	sscanf Write("I?"), "I?%d", initialised
	Return initialised
End

Function GetExercised()
	Return (GetStatus() & 2) > 0
End

Function GetMinWavelength()
	Return 500
End

Function GetMaxWavelength()
	Return 720
End

Function GetBandwidth()
	Return 10
End

Static Function /S Write(command)
	String command
	Serial#SetActive(GetActive())
	Return Serial#Write(command)
End

Static Function GetStatus()
	Variable status
	sscanf Write("@"), "@%c", status
	Return status
End

Static Function IsActive()
	Return Package#IsActive(this)
End

Static Function /DF Home()
	Return Package#ActiveFolder(this)
End
