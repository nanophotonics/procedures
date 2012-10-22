#pragma ModuleName = Files
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

Function /S CleanPath(path)
	String path

	path = ParseFilePath(5, path, ":", 0, 0)

	If (strlen(ParseFilePath(4, path, ":", 0, 0)) == 0)
		path = ParseFilePath(2, path, ":", 0, 0)
	EndIf

	Return path
End

Function /S ListFiles(path, [extension, select, reject])
	String path, extension, select, reject

	If (ParamIsDefault(extension))
		extension = "????"
	EndIf
	If (ParamIsDefault(select))
		select = ""
	EndIf
	If (ParamIsDefault(reject))
		reject = ""
	EndIf

	NewPath /Q /Z /O list_files, path

	If (!V_flag)
		String files = IndexedFile(list_files, -1, extension)

		If (strlen(select))
			files = ListSelect(files, select)
		EndIf

		If (strlen(reject))
			files = ListReject(files, reject)
		EndIf

		Return files
	Else
		Return ""
	EndIf
End

Function /S ListFolders(path, [select, reject, relative])
	String path, select, reject
	Variable relative

	If (ParamIsDefault(select))
		select = ""
	EndIf
	If (ParamIsDefault(reject))
		reject = ""
	EndIf
	If (ParamIsDefault(relative))
		relative = false
	EndIf

	NewPath /Q /Z /O list_folders, path

	If (!V_flag)
		String folders = IndexedDir(list_folders, -1, !relative)

		If (strlen(select))
			folders = ListSelect(folders, select)
		EndIf

		If (strlen(reject))
			folders = ListReject(folders, reject)
		EndIf

		Return folders
	Else
		Return ""
	EndIf
End

Function ForEachFile(path, action, [extension, select, reject])
	String path
	FuncRef ForEachPathAction action
	String extension, select, reject

	If (ParamIsDefault(extension))
		extension = "????"
	EndIf
	If (ParamIsDefault(select))
		select = ""
	EndIf
	If (ParamIsDefault(reject))
		reject = ""
	EndIf

	path = CleanPath(path)
	String files = ListFiles(path, extension=extension, select=select, reject=reject)
	Variable count = ItemsInList(files)

	Variable file
	For (file = 0; file < count; file += 1)
		action(path + StringFromList(file, files))
	EndFor

	Return count
End

Function ForEachFolder(path, action, [select, reject])
	String path
	FuncRef ForEachPathAction action
	String select, reject

	If (ParamIsDefault(select))
		select = ""
	EndIf
	If (ParamIsDefault(reject))
		reject = ""
	EndIf

	Variable count = 0

	NewPath /Q /Z /O for_each_folder, path

	If (!V_flag)
		String folders = IndexedDir(for_each_folder, -1, 1)

		If (strlen(select))
			folders = ListSelect(folders, select)
		EndIf

		If (strlen(reject))
			folders = ListReject(folders, reject)
		EndIf

		Variable folder
		For (folder = 0, count = ItemsInList(folders); folder < count; folder += 1)
			action(StringFromList(folder, folders))
		EndFor
	EndIf

	Return count
End

Function ForEachPathAction(path)
	String path

	Abort "Invalid function"
End

Function FileExists(path)
	String path

	GetFileFolderInfo /Q /Z path
	Return !V_Flag && V_isFile
End

Function FolderExists(path)
	String path

	GetFileFolderInfo /Q /Z path
	Return !V_Flag && V_isFolder
End
