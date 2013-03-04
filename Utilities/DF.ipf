#pragma ModuleName = DF
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

#include "Package"

Static StrConstant this = "DF"

Static Function New()
	DFRef previous = GetDataFolderDFR()

	Package#New(this)

	SetDataFolder Home()
	Variable /G count
	Make /DF /N=32 stored

	SetDataFolder previous
End

Static Function Push()
	EnsureExists()

	Wave /DF /SDFR=Home() stored
	NVar /SDFR=Home() count

	If (count == numpnts(stored))
		Redimension /N=(count * 2) stored
	EndIf

	stored[count] = GetDataFolderDFR()

	count += 1
End

Static Function Set(folder)
	DFRef folder

	Push()
	SetDataFolder folder
End

Static Function Free()
	Set(NewFreeDataFolder())
End

Static Function Pop()
	EnsureExists()

	Wave /DF /SDFR=Home() stored
	NVar /SDFR=Home() count

	If (count > 0)
		count -= 1

		SetDataFolder stored[count]
		stored[count] = $""
	EndIf
End

Static Function Clear()
	EnsureExists()

	Wave /DF /SDFR=Home() stored
	NVar /SDFR=Home() count

	If (count > 0)
		count = 0
		stored = $""
	EndIf
End

Static Function /DF Home()
	Return Package#Folder(this)
End

Static Function EnsureExists()
	If (!Package#Status(this))
		New()
	EndIf
End
