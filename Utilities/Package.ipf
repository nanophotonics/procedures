#pragma ModuleName = Package
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

Static Function New(package, [path])
	String package
	String path

	If (ParamIsDefault(path))
		path = ""
	EndIf

	DFRef previous = GetDataFolderDFR()

	NewDataFolder /O /S root:Packages
	NewDataFolder /O /S $package

	If (strlen(path) > 0)
		NewDataFolder /O $(":" + path)
	EndIf

	SetDataFolder previous
End

Static Function Status(package, [path])
	String package
	String path

	If (ParamIsDefault(path))
		path = ""
	EndIf

	Return DataFolderRefStatus(Folder(package, path=path))
End

Static Function /DF Folder(package, [path])
	String package
	String path

	If (ParamIsDefault(path))
		path = ""
	EndIf

	If (strlen(path) > 0)
		package += ":" + path
	EndIf

	Return $("root:Packages:" + package)
End

Static Function /DF ActiveFolder(package, [path])
	String package
	String path

	If (ParamIsDefault(path))
		path = ""
	EndIf

	String active = GetActive(package)
	If (strlen(active) > 0)
		If (strlen(path) > 0)
			active += ":" + path
		EndIf
		Return Folder(package, path=active)
	EndIf
End

Static Function Delete(package, [path])
	String package
	String path

	If (ParamIsDefault(path))
		path = ""
	EndIf

	If (Status(package, path=path))
		KillDataFolder Folder(package, path=path)
		If (strlen(path) > 0 && CmpStr(path, GetActive(package)) == 0)
			SetActive(package, "")
		EndIf
	EndIf
End

Static Function /S GetActive(package)
	String package

	SVar /Z /SDFR=Folder(package) active

	If (SVar_Exists(active))
		Return active
	Else
		Return ""
	EndIf
End

Static Function SetActive(package, active)
	String package
	String active

	DFRef path = Folder(package)
	String /G path:active = active
End

Static Function IsActive(package)
	String package

	Return strlen(GetActive(package)) > 0
End
