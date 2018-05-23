# Set PS Execution Policy
If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy RemoteSigned -Force}

# Make current network private if not already domain
Get-NetConnectionProfile | Where {($_.IPv4Connectivity -eq 'Internet') -And ($_.NetworkCategory -ne 'Domain')} | % {Try {Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private} Catch {}}

# WinRM
# winrm quickconfig

# Set System Recovery to On/5%
Try {Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop; $null = & vssadmin resize shadowstorage /For=$env:SystemDrive /On=$env:SystemDrive /Maxsize="5%"} Catch {}

# Turn off .Net 3.5
If ((Get-WindowsOptionalFeature -Online | Where {$_.FeatureName -eq 'NetFx3'}).State -eq 'Enabled') {Disable-WindowsOptionalFeature –FeatureName 'NetFx3' –Online -NoRestart -WarningAction SilentlyContinue | Out-Null}

# Remove Camera App
If ((Get-CimInstance Win32_PnPEntity | Where Caption -Like '*cam*').PNPDeviceID -eq $null) {
	Get-AppxPackage | Where {$_.Name -eq 'Microsoft.WindowsCamera'} | Remove-AppxPackage | Out-Null
	Get-AppxPackage -AllUsers | Where {$_.Name -eq 'Microsoft.WindowsCamera'} | Remove-AppxPackage | Out-Null
	Try {Get-AppXProvisionedPackage -Online | Where { $_.DisplayName -eq 'Microsoft.WindowsCamera' } | Remove-AppxProvisionedPackage -Online | Out-Null} Catch {}
}

# Remove OneDrive
Do {
    $od1 = Get-Process OneDriveSetup.exe -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 200
} Until ($od1 –eq $Null)

$od2 = Get-Process OneDrive -ErrorAction SilentlyContinue
If ($od2 -ne $null) {Start-Sleep -Seconds 5}
$od2 | Stop-Process -Force
Do {
    $od2 = Get-Process OneDrive -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 200
} Until ($od2 –eq $Null)
Start-Sleep -Seconds 1

Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" "/uninstall" -NoNewWindow -Wait | Out-Null

$cuUninstall = (Get-ItemProperty 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe' -EA 0).UninstallString
If ($cuUninstall -ne $null) {Start-Process $cuUninstall -NoNewWindow -Wait | Out-Null}

If (Test-Path "$env:SystemDrive\OneDriveTemp") {Remove-Item "$env:SystemDrive\OneDriveTemp" -Force -Recurse}
If (Test-Path "$env:USERPROFILE\OneDrive") {Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse}
If (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive") {Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse}
If (Test-Path "$env:ProgramData\Microsoft OneDrive") {Remove-Item "$env:ProgramData\Microsoft OneDrive" -Force -Recurse}
If (Test-Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk") {Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force -Recurse}
Try {New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR -EA 0 | Out-Null} Catch {}
If (Test-Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") {Remove-Item "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Force -Recurse}
If (Test-Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") {Remove-Item "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Force -Recurse}
If (Test-Path "HKLM:\Software\Policies\Microsoft\Windows\OneDrive") {Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\OneDrive" -Name DisableFileSyncNGSC -Value 1 -ErrorAction SilentlyContinue -Force}

# Rename Admin
$localAdmin = Get-WMIObject Win32_UserAccount -Filter "SID='S-1-5-21-166345611-2250139348-1836178157-500'" -ErrorAction SilentlyContinue
If (($localAdmin -ne $null) -And ($localAdmin.Name -ne 'ElevatedLocalAccount')) {$rename = $localAdmin.Rename('ElevatedLocalAccount')}

# Remove AutoAdminLogon
Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value "" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value "" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value "0" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultDomainName -Value "" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' -Name LastLoggedOnSAMUser -Value "" -Force -ErrorAction SilentlyContinue

Restart-Computer -Force
Exit