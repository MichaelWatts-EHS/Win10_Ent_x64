﻿# Execution policy must be RemoteSigned or Unrestricted

#REQUIRES -Version 4
#REQUIRES -RunAsAdministrator

[CmdletBinding()]
Param([Parameter(Mandatory=$False,Position=0)] [string] $PutPath = "$env:SystemDrive\MODWIM")

Try {
    If (!(Test-Path $PutPath)) {New-Item -ItemType Directory -Force -Path $PutPath | Out-Null}
    If (!(Test-Path "$putPath\Mod-Wim.ps1")) {$client = new-object System.Net.WebClient; $client.DownloadFile('https://raw.githubusercontent.com/MichaelWatts-EHS/Win10_Ent_x64/master/Mod-Wim.ps1', "$putPath\Mod-Wim.ps1")}
    If (Test-Path "$putPath\Mod-Wim.ps1") {. "$putPath\Mod-Wim.ps1"}
} Catch {}