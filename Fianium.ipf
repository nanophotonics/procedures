#pragma IndependentModule = Fianium
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

#include "Package"
#include "Serial"
#include "Logger"
#include "Utilities"

Static StrConstant this = "Fianium"

Function New([port, rampStep, rampInterval])
	String port
	Variable rampStep
	Variable rampInterval

	If (ParamIsDefault(port))
		Prompt port, "Choose laser control serial port:", popup, Serial#GetPorts()
		DoPrompt "Locate Fianium", port
		If (V_Flag)
			Abort
		EndIf
	EndIf
	If (ParamIsDefault(rampStep))
		rampStep = 100
	EndIf
	If (ParamIsDefault(rampInterval))
		rampInterval = 18
	EndIf

	Delete(port=port)
	Package#New(this, path=port)

	SetActive(port)
	SetRampStep(rampStep)
	SetRampInterval(rampInterval)

	Serial#New(port=port, baud=19200, in=2, out=2)
	Logger#New(name=GetLog(), function="Logger", parameter=port)

	Initialise()
End

Function Initialise([port])
	String port

	If (ParamIsDefault(port))
		port = ""
	EndIf

	If (strlen(port) == 0)
		If (IsActive())
			port = GetActive()
		Else
			Abort "Could not initialise Fianium. No active laser found."
		EndIf
	EndIf

	If (!Package#Status(this, path=port))
		Abort "Could not initialise Fianium. " + port + " data not found."
	EndIf

	SetActive(port)

	Serial#Initialise(port=port)

	Logger#Initialise(name=GetLog())
End

Function Delete([port])
	String port

	If (ParamIsDefault(port))
		port = GetActive()
	EndIf

	Serial#Delete(port=port)
	Logger#Delete(name=GetLog(port=port))
	Package#Delete(this, path=port)
End

Function StartLog()
	Logger#SetActive(GetLog())
	Logger#Start()
End

Function StopLog()
	Logger#SetActive(GetLog())
	Logger#Stop()
End

Function PauseLog()
	Logger#SetActive(GetLog())
	Logger#Pause()
End

Function RampPower(power, [rampStep, rampInterval])
	Variable power, rampStep, rampInterval

	Variable previous = GetPower()

	If (ParamIsDefault(rampStep))
		rampStep = GetRampStep()
	EndIf
	If (ParamIsDefault(rampInterval))
		rampInterval = GetRampInterval()
	EndIf

	If (power < previous)
		rampStep *= -1
	EndIf

	Do
		If (abs(power - previous) <= abs(rampStep))
			SetPower(power)
			Break
		EndIf

		previous += rampStep
		SetPower(previous)
		Sleep /T rampInterval
	While (1)
End

Function /S GetActive()
	Return Package#GetActive(this)
End

Function SetActive(port)
	String port
	Package#SetActive(this, port)
End

Function GetRampStep()
	NVar /SDFR=Active() rampStep
	Return rampStep
End

Function SetRampStep(rampStep)
	Variable rampStep
	DFRef folder = Active()
	Variable /G folder:rampStep = rampStep
End

Function GetRampInterval()
	NVar /SDFR=Active() rampInterval
	Return rampInterval
End

Function SetRampInterval(rampInterval)
	Variable rampInterval
	DFRef folder = Active()
	Variable /G folder:rampInterval = rampInterval
End

Function /S GetAlarm()
	Return Write("A?")
End

Function HasAlarm()
	Return cmpstr(GetAlarm(), "No alarms") != 0
End

Function ClearAlarm()
	Write("A=0")
End

Function GetPower()
	Variable power
	sscanf Write("Q?"), " Puma current = %*f DAC Level = %f", power
	Return power
End

Function SetPower(power)
	Variable power
	Write("Q=" + num2istr(power))
End

Function GetPumaCurrent()
	Variable power
	sscanf Write("Q?"), " Puma current = %f", power
	Return power
End

Function GetBackReflection()
	Variable backReflection
	sscanf Write("B?"), " Back reflection photodiode = %f", backReflection
	Return backReflection
End

Function GetPreamplifier()
	Variable preamplifier
	sscanf Write("P?"), " Preamplifier photodiode = %f", preamplifier
	Return preamplifier
End

Function /S GetVersion()
	Return Write("V?")
End

Static Function /S Write(command)
	String command

	Serial#SetActive(GetActive())
	Return RemoveEnding(Serial#Write(command), "\nCommand>\n")
End

Function Logger(port, folder)
	String port
	DFRef folder

	SetActive(port)

	Variable /G folder:power = GetPower()
	Variable /G folder:pumaCurrent = GetPumaCurrent()
	Variable /G folder:backReflection = GetBackReflection()
	Variable /G folder:preamplifier = GetPreamplifier()
End

Static Function /S GetLog([port])
	String port

	If (ParamIsDefault(port))
		port = GetActive()
	EndIf

	Return "Fianium_" + port
End

Static Function IsActive()
	Return Package#IsActive(this)
End

Static Function /DF Active()
	Return Package#ActiveFolder(this)
End
