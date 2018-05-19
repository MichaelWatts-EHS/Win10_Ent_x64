$putPath = 'C:\MODWIM'
If (!(Test-Path $putPath)) {New-Item -ItemType Directory -Force -Path $putPath | Out-Null}; If (!(Test-Path "$putPath\Mod-Wim.ps1")) {$client = new-object System.Net.WebClient; $client.DownloadFile('https://raw.githubusercontent.com/MichaelWatts-EHS/Win10_Ent_x64/master/Mod-Wim.ps1', "$putPath\Mod-Wim.ps1")}
If (Test-Path "$putPath\Mod-Wim.ps1") {. "$putPath\Mod-Wim.ps1"}
