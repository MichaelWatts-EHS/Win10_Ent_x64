#$putPath = 'C:\MODWIM'
#If (!(Test-Path $putPath)) {New-Item -ItemType Directory -Force -Path $putPath | Out-Null}; If (!(Test-Path "$putPath\Mod-Wim.ps1")) {$client = new-object System.Net.WebClient; $client.DownloadFile('https://raw.githubusercontent.com/MichaelWatts-EHS/Win10_Ent_x64/master/Mod-Wim.ps1', "$putPath\Mod-Wim.ps1")}
#If (Test-Path "$putPath\Mod-Wim.ps1") {. "$putPath\Mod-Wim.ps1"}

[cmdletbinding()]
Param ()
#REQUIRES -Version 4
#REQUIRES -Modules Dism
#REQUIRES -RunAsAdministrator
# =================================================================================
# Warning!
# McAfee's OA scanner and even File Explorer will interfere with the process
# Turn them off and keep them closed while running
# =================================================================================
Clear-Host

# The path where this script is located.  Everything else is relative
$sRoot = $PSScriptRoot

# Cleanup any leftovers from previous runs
If (Test-Path "$sRoot\BootDisk.iso") {Remove-Item "$sRoot\BootDisk.iso" -Force}
If (Test-Path "$sRoot\MEDIA") {Remove-Item "$sRoot\MEDIA" -Force -Recurse}
If (Test-Path "$sRoot\WORKWIM") {Remove-Item "$sRoot\WORKWIM" -Force -Recurse}
If (Test-Path "$sRoot\MOUNT") {Try {Remove-Item "$sRoot\MOUNT" -Force -Recurse} Catch {Clear-WindowsCorruptMountPoint | Out-Null; Try {Remove-Item "$sRoot\MOUNT" -Force -Recurse} Catch {Write-Host "$sRoot\MOUNT could not be removed. Delete it and run again." -ForegroundColor Red; Break}}}

# Setup the basic folders and files we will use
If (!(Test-Path "$sRoot\_SOURCE")) {New-Item -Path $sRoot -Name '_SOURCE' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\bin")) {New-Item -Path $sRoot -Name '_SOURCE\bin' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\drivers")) {New-Item -Path $sRoot -Name '_SOURCE\drivers' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\iso")) {New-Item -Path $sRoot -Name '_SOURCE\iso' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\oem")) {New-Item -Path $sRoot -Name '_SOURCE\oem' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\ps")) {New-Item -Path $sRoot -Name '_SOURCE\ps' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\sxs")) {New-Item -Path $sRoot -Name '_SOURCE\sxs' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\updates")) {New-Item -Path $sRoot -Name '_SOURCE\updates' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\unattend")) {New-Item -Path $sRoot -Name '_SOURCE\unattend' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\wim")) {New-Item -Path $sRoot -Name '_SOURCE\wim' -ItemType Directory | Out-Null}
If (!(Test-Path "$sRoot\_SOURCE\ps\New-ISO.ps1")) {$client = new-object System.Net.WebClient; $client.DownloadFile('https://raw.githubusercontent.com/MichaelWatts-EHS/Win10_Ent_x64/master/_SOURCE/ps/New-ISO.ps1', "$sRoot\_SOURCE\ps\New-ISO.ps1")}

# Check to be sure we have the base iso
$sourceISO = (Get-ChildItem "$sRoot\_SOURCE\iso" -Filter *.iso | Select -First 1).FullName
If ($sourceISO -eq $null) {
    Write-Host 'Select the ISO to use as the baseline'
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = "$sRoot\_SOURCE\iso"
    $OpenFileDialog.filter = "ISO (*.iso)| *.iso"
    $OpenFileDialog.ShowDialog() | Out-Null
    If ($OpenFileDialog.filename -eq $null) {Write-Host "Process cancelled by user" -ForegroundColor Red; Break}
    Copy-Item "$($OpenFileDialog.filename)" -Destination "$sRoot\_SOURCE\iso" -Force
    $sourceISO = (Get-ChildItem "$sRoot\_SOURCE\iso" -Filter *.iso | Select -First 1).FullName   
}

# Unpack the media and clean it up
If ($sourceISO) {
    If (!(Test-Path "$sRoot\MEDIA")) {New-Item -Path $sRoot -Name 'MEDIA' -ItemType Directory | Out-Null}
    $mount = Mount-DiskImage -ImagePath $sourceISO -PassThru
    $mountdrive = ($mount | Get-Volume).DriveLetter+":"
    Write-Host 'Copying files from the iso'
    Copy-Item "$mountdrive\*" -Destination "$sRoot\MEDIA" -Force -Recurse
    Dismount-DiskImage -ImagePath $sourceISO
}
If (!(Test-Path "$sRoot\MEDIA\sources\install.wim")) {Write-Host "Houston we have a problem.  Check " -NoNewline; Write-Host "$sRoot\MEDIA\sources\install.wim" -NoNewline -ForegroundColor Red; Write-Host " and try again"; Break}

# Cleanup the media
Set-ItemProperty "$sRoot\MEDIA\sources\install.wim" -Name IsReadOnly -Value $False
If (Test-Path "$sRoot\MEDIA\autorun.inf") {Remove-Item "$sRoot\MEDIA\autorun.inf" -Force}
If (Test-Path "$sRoot\MEDIA\autounattend.xml") {Remove-Item "$sRoot\MEDIA\autounattend.xml" -Force}
If (Test-Path "$sRoot\MEDIA\sources\`$OEM`$") {Remove-Item "$sRoot\MEDIA\sources\`$OEM`$" -Force -Recurse}
If (Test-Path "$sRoot\MEDIA\boot\fonts") {Remove-Item "$sRoot\MEDIA\boot\fonts" -Force -Recurse}
If (Test-Path "$sRoot\MEDIA\efi\microsoft\boot\fonts") {Remove-Item "$sRoot\MEDIA\efi\microsoft\boot\fonts" -Force -Recurse}
If (!(Test-Path "$sRoot\_SOURCE\bin\efisys.bin") -And (Test-Path "$sRoot\MEDIA\efi\microsoft\boot\efisys.bin")) {Copy-Item "$sRoot\MEDIA\efi\microsoft\boot\efisys.bin" -Destination "$sRoot\_SOURCE\bin\efisys.bin" -Force}
If (!(Test-Path "$sRoot\_SOURCE\wim\install.wim")) {Copy-Item "$sRoot\MEDIA\sources\install.wim" -Destination "$sRoot\_SOURCE\wim" -Force}
Move-Item -Path "$sRoot\MEDIA\sources\sxs\Microsoft-Windows-NetFx3*" -Destination "$sRoot\_SOURCE\sxs" -Force
If (Test-Path "$sRoot\_SOURCE\ps\New-ISO.ps1") {. "$sRoot\_SOURCE\ps\New-ISO.ps1"}
If (Test-Path "$sRoot\_SOURCE\Unattend\autounattend.xml") {
    Copy-Item "$sRoot\_SOURCE\Unattend\autounattend.xml" -Destination "$sRoot\MEDIA\autounattend.xml" -Force
    $efiCheck = 0
    ForEach ($line In (Get-Content "$sRoot\_SOURCE\Unattend\autounattend.xml")) {
        If ($line -like "*<settings pass=`"windowsPE`">*") {$efiCheck++}
        If ($line -like "*<Type>EFI</Type>*") {$efiCheck++}
        If ($line -like "*<Type>MSR</Type>*") {$efiCheck++}
    }
    If ((Test-Path "$sRoot\MEDIA\bootmgr") -And ($efiCheck -ge 3)) {Remove-Item "$sRoot\MEDIA\bootmgr" -Force}
}

# Clean out the working folder and get a clean copy of install.wim
If (!(Test-Path "$sRoot\WORKWIM")) {New-Item -Path $sRoot -Name 'WORKWIM' -ItemType Directory | Out-Null}
Move-Item -Path "$sRoot\MEDIA\sources\install.wim" -Destination "$sRoot\WORKWIM\install_0.wim" -Force

# Find and export the image we want
$arrImages = Get-WindowsImage -ImagePath "$sRoot\WORKWIM\install_0.wim"
If ($arrImages.Count -eq 0) {Write-Host "There are " -NoNewline; Write-Host "0" -NoNewline -ForegroundColor Red; Write-Host " images in the wim! Aborting"; Break}
ElseIf ($arrImages.Count -eq 1) {Write-Host "There is " -NoNewline; Write-Host "1" -NoNewline -ForegroundColor Yellow; Write-Host " image in the wim.  " -NoNewline}
ElseIf ($arrImages.Count -gt 1) {Write-Host "There are " -NoNewline; Write-Host "$($arrImages.Count)" -NoNewline -ForegroundColor Yellow; Write-Host " images in the wim.  " -NoNewline}
$iIndex = ($arrImages | Where {$_.ImageName -eq 'Windows 10 Enterprise'}).ImageIndex
If ($iIndex) {Write-Host "Index #$iIndex is the one we want"} Else {Write-Host "'Windows 10 Enterprise' isn't one of them.  Aborting" -ForegroundColor Red; Break}
Try {Export-WindowsImage -SourceImagePath "$sRoot\WORKWIM\install_0.wim" -SourceIndex $iIndex -DestinationImagePath "$sRoot\WORKWIM\install.wim" -DestinationName 'Windows 10 Enterprise' | Out-Null} Catch {}
If (!(Test-Path "$sRoot\WORKWIM\install.wim")) {Write-Host "Danger, Danger, Will Robinson" -ForegroundColor Red; Break}
Remove-Item "$sRoot\WORKWIM\install_0.wim" -Force

# Check the folders that need to be populated
Write-Host "Sanity check!" -ForegroundColor Cyan
Read-Host "Press [ENTER] to continue ..."
$arrUpdates = Get-ChildItem "$sRoot\_SOURCE\updates\*" -Include *.msu,*.cab -Recurse
$arrDrivers = Get-ChildItem "$sRoot\_SOURCE\drivers\*" -Include *.inf -Recurse
$arroem = Get-ChildItem "$sRoot\_SOURCE\oem\*" -Force -Recurse | Where { !($_.PSIsContainer) }

# Mount the wim for editing
If (!(Test-Path "$sRoot\MOUNT")) {New-Item -Path $sRoot -Name 'MOUNT' -ItemType Directory | Out-Null}
$ret = Mount-WindowsImage -ImagePath "$sRoot\WORKWIM\install.wim" -Index 1 -Path "$sRoot\MOUNT"

# Check the NetFx3 payload and restore if needed. We also remove it from the media to make the final iso smaller
If ((Get-ChildItem "$sRoot\_SOURCE\sxs" -Filter "Microsoft-Windows-NetFx3*.cab").Count -ge 2) {
    If ((Get-WindowsOptionalFeature -Path "$sRoot\MOUNT" -FeatureName NetFx3).State -eq 'DisabledWithPayloadRemoved') {
        Write-Host 'Restoring NetFx3 payload'
        Enable-WindowsOptionalFeature -Path "$sRoot\MOUNT" -FeatureName NetFx3 -Source "$sRoot\_SOURCE\sxs" -LimitAccess -NoRestart | Out-Null
    }
}

# Add updates that we've downloaded from the Windows Update Catalog:  https://www.catalog.update.microsoft.com
Write-Host "Updates found: $($arrUpdates.Count)"
If ($arrUpdates.Count -gt 0) {
    ForEach ($upd In $arrUpdates) {
        Write-Host "   $($upd.Name)"
        Add-WindowsPackage -Path "$sRoot\MOUNT" -PackagePath "$sRoot\_SOURCE\updates\$($upd.Name)" | Out-Null
    }
}

# Add any drivers we've put in the drivers folders
Write-Host "Drivers found: $($arrDrivers.Count)"
If ($arrDrivers.Count -gt 0) {Add-WindowsDriver -Path "$sRoot\MOUNT" -Driver "$sRoot\_SOURCE\drivers" -Recurse}

# Add OEM files.  Careful, it will copy everything AS IS including hidden files, thumbnails, desktop.ini, etc.  Delete these before running
Write-Host "OEM files: $($arroem.Count)"
Copy-Item "$sRoot\_SOURCE\OEM\*" -Destination "$sRoot\MOUNT" -Force -Recurse

# Remove *&^%$#@ ... I mean the wonderful and very useful tools that MS thinks every ENTERPRISE user needs to have 
# Since we're doing it in the offline image they are GONE, never to be seen again (or until MS puts them back) 
# Define the packages that should be left alone
$goodApps = @(
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsCalculator"
    "Microsoft.WindowsStore"
    "Microsoft.DesktopAppInstaller"     # it's invisible but frags the Store if removed
)
# Everything else is toast
$badApps  = Get-AppxProvisionedPackage -Path "$sRoot\MOUNT" | Where {!($goodApps -like $_.DisplayName)} 
Write-Host "Bloatware found: $($badApps.Count)"
ForEach ($app In $badApps) {
    Write-Host "   $($app.DisplayName)"
    Remove-AppxProvisionedPackage -Path "$sRoot\MOUNT" -PackageName $($app.PackageName) | Out-Null
}
# Because the Start Menu looks like cr@p when you all the blatant commercialism, we give it a nice clean makeover
# We also take the opportunity to clean the Taskbar and swap IE for Edge. Don't ask why the built in IE shortcut can't be used just accept it
If (!(Test-Path "$sRoot\MOUNT\ProgramData\Microsoft\Windows\Start Menu\Programs\Internet Explorer.lnk")) {
    If (Test-Path "$sRoot\MOUNT\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\Internet Explorer.lnk") {Copy-Item "$sRoot\MOUNT\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\Internet Explorer.lnk" -Destination "$sRoot\MOUNT\ProgramData\Microsoft\Windows\Start Menu\Programs\Internet Explorer.lnk" -Force}
    Else {$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$sRoot\MOUNT\ProgramData\Microsoft\Windows\Start Menu\Programs\Internet Explorer.lnk"); $Shortcut.TargetPath = "C:\Program Files\Internet Explorer\iexplore.exe"; $Shortcut.Save();}
}
If (!(Test-Path "$sRoot\MOUNT\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml")) {
    $layoutData = @"
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <LayoutOptions StartTileGroupCellWidth="6" />
  <DefaultLayoutOverride LayoutCustomizationRestrictionType="OnlySpecifiedGroups">
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout">
        <start:Group Name="Browsers" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout">
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Internet Explorer.lnk" />
          <start:DesktopApplicationTile Size="1x1" Column="2" Row="1" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" />
          <start:Tile Size="1x1" Column="2" Row="0" AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
        </start:Group>
        <start:Group Name="Microsoft Office" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout">
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Outlook 2016.lnk" />
          <start:DesktopApplicationTile Size="1x1" Column="2" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Word 2016.lnk" />
          <start:DesktopApplicationTile Size="1x1" Column="2" Row="1" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Excel 2016.lnk" />
          <start:DesktopApplicationTile Size="1x1" Column="3" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Access 2016.lnk" />
          <start:DesktopApplicationTile Size="1x1" Column="3" Row="1" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\PowerPoint 2016.lnk" />
        </start:Group>
      </defaultlayout:StartLayout>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Accessories\Internet Explorer.lnk" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@ | Out-File "$sRoot\MOUNT\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Encoding utf8
}

# Don't argue just let it ride.  Besides, all it does is implode
$setupxvbs = @"
On Error Resume Next
Set oWSH = CreateObject("Wscript.Shell")
Set oUAC = CreateObject("Shell.Application")
Set oFSO = CreateObject("Scripting.FileSystemObject")
oFSO.DeleteFile Wscript.ScriptFullName

'If oFSO.FileExists(oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\SetupX.ps1") Then oUAC.ShellExecute "PowerShell.exe", "-ExecutionPolicy Bypass -Command ""&{" & oWSH.ExpandEnvironmentStrings("%ALLUSERSPROFILE%") & "\SetupX.ps1" & "}""", "", "runas", 2
"@ | Out-File "$sRoot\MOUNT\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\SetupX.vbs"


# Stick the landing
Try {
    Write-Host 'Dismounting the image'
    Dismount-WindowsImage -Path "$sRoot\MOUNT" -Save | Out-Null
    Remove-Item "$sRoot\MOUNT" -Force -Recurse
    Move-Item -Path "$sRoot\WORKWIM\install.wim" -Destination "$sRoot\MEDIA\sources\install.wim" -Force
    Remove-Item "$sRoot\WORKWIM" -Force -Recurse
} Catch {}


# Bob's your uncle
If ($bootbin) {
    Write-Host "Creating ISO: `t`t " -NoNewline
    DIR "$sRoot\MEDIA" | New-IsoFile -Path "$sRoot\BootDisk.iso" -BootFile $bootbin -Media DISK -Title "BootDisk" | Out-Null
    Write-Host "$sRoot\BootDisk.iso" -ForegroundColor Cyan
    & Explorer "$sRoot\"
} Else {
    Write-Host "Here you go: `t`t " -NoNewline; Write-Host "$sRoot\MEDIA" -ForegroundColor Cyan
    & Explorer "$sRoot\MEDIA\"
}
Write-Host "`n`nAnd there was much rejoicing" -ForegroundColor Green