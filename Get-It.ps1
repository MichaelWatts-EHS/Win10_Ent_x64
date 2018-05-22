#REQUIRES -Version 4
#REQUIRES -RunAsAdministrator
# Execution policy must be RemoteSigned or Unrestricted

# Create the working directory
$putPath = 'C:\MODWIM'
If (!(Test-Path $putPath)) {New-Item -ItemType Directory -Force -Path $putPath | Out-Null}

# Get the main script and run it
If (!(Test-Path "$putPath\Mod-Wim.ps1")) {$client = new-object System.Net.WebClient; $client.DownloadFile('https://raw.githubusercontent.com/MichaelWatts-EHS/Win10_Ent_x64/master/Mod-Wim.ps1', "$putPath\Mod-Wim.ps1")}
If (Test-Path "$putPath\Mod-Wim.ps1") {. "$putPath\Mod-Wim.ps1"}