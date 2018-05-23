# Execution policy must be RemoteSigned or Unrestricted

#REQUIRES -Version 4
#REQUIRES -RunAsAdministrator

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=0)] [string] $PutPath = "$env:SystemDrive\MODWIM",
    [Parameter(Mandatory=$False,Position=1)] [string] $GetPath = "https://raw.githubusercontent.com/MichaelWatts-EHS/Win10_Ent_x64/master"
)

Try {
    If (!(Test-Path $PutPath)) {New-Item -ItemType Directory -Force -Path $PutPath | Out-Null}
    If (!(Test-Path "$putPath\Mod-Wim.ps1")) {$client = new-object System.Net.WebClient; $client.DownloadFile("$GetPath/Mod-Wim.ps1", "$putPath\Mod-Wim.ps1")}
    If (Test-Path "$putPath\Mod-Wim.ps1") {. "$putPath\Mod-Wim.ps1" $GetPath}
} Catch {}