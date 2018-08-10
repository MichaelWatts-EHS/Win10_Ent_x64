# Suicide script
If (Test-Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\StartUp\SetupX.lnk") {Remove-Item "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\StartUp\SetupX.lnk" -Force -ErrorAction SilentlyContinue}
If (Test-Path "$env:ALLUSERSPROFILE\SetupX.lnk") {Remove-Item "$env:ALLUSERSPROFILE\SetupX.lnk" -Force -ErrorAction SilentlyContinue}
If (Test-Path "$env:ALLUSERSPROFILE\SetupX.vbs") {Remove-Item "$env:ALLUSERSPROFILE\SetupX.vbs" -Force -ErrorAction SilentlyContinue}
Remove-Item $MyINvocation.InvocationName -Force -ErrorAction SilentlyContinue

# Make current network private if not already domain
Get-NetConnectionProfile | Where {($_.IPv4Connectivity -eq 'Internet') -And ($_.NetworkCategory -ne 'Domain')} | % {Try {Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private} Catch {}}

# Remove Camera App if hardware is not detected
If ((Get-CimInstance Win32_PnPEntity | Where Caption -Match 'camera').PNPDeviceID -eq $null) {Get-AppxPackage | Where {$_.Name -eq 'Microsoft.WindowsCamera'} | Remove-AppxPackage | Out-Null; Get-AppxPackage -AllUsers | Where {$_.Name -eq 'Microsoft.WindowsCamera'} | Remove-AppxPackage | Out-Null; Try {Get-AppXProvisionedPackage -Online | Where { $_.DisplayName -eq 'Microsoft.WindowsCamera' } | Remove-AppxProvisionedPackage -Online | Out-Null} Catch {}}

# Set System Recovery to On/5%
Try {Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop; $null = & vssadmin resize shadowstorage /For=$env:SystemDrive /On=$env:SystemDrive /Maxsize="5%"} Catch {}

# Remove AutoAdminLogon
Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value "" -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value "" -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0 -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value "0" -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultDomainName -Value "" -Force -ErrorAction SilentlyContinue; Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' -Name LastLoggedOnSAMUser -Value "" -Force -ErrorAction SilentlyContinue

# Turn off .Net 3.5
# If ((Get-WindowsOptionalFeature -Online | Where {$_.FeatureName -eq 'NetFx3'}).State -eq 'Enabled') {Try {Disable-WindowsOptionalFeature –FeatureName 'NetFx3' –Online -NoRestart -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null} Catch {}}

# Rename Admin
# $localAdmin = Get-WMIObject Win32_UserAccount -Filter "SID LIKE 'S-1-5-%' and SID LIKE '%-500'" -ErrorAction SilentlyContinue; If (($localAdmin -ne $null) -And ($localAdmin.Name -ne 'ElevatedLocalAccount')) {$rename = $localAdmin.Rename('ElevatedLocalAccount')}

# Reboot
Restart-Computer -Force
