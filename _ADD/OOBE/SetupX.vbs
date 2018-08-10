On Error Resume Next
Set oWSH = CreateObject("Wscript.Shell")
Set oUAC = CreateObject("Shell.Application")
Set oFSO = CreateObject("Scripting.FileSystemObject")
oFSO.DeleteFile(Wscript.ScriptFullName)
If oFSO.FileExists(oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\SetupX.vbs") Then oFSO.DeleteFile oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\SetupX.vbs"
If oFSO.FileExists(oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\SetupX.lnk") Then oFSO.DeleteFile oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\SetupX.lnk"
If oFSO.FileExists(oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\Microsoft\Windows\Start Menu\Programs\StartUp\SetupX.lnk") Then oFSO.DeleteFile oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\Microsoft\Windows\Start Menu\Programs\StartUp\SetupX.lnk"
If oFSO.FileExists(oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\SetupX.ps1") Then oUAC.ShellExecute "PowerShell.exe", "-ExecutionPolicy Bypass -Command ""&{" & oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\SetupX.ps1" & "}""", "", "runas", 2
