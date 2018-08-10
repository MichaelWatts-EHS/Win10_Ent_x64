@Echo Off
SET LOGFILE="%~dp0SetupX.log"
@Echo Begin Specialization >>"%LOGFILE%"
@Echo %DATE% %TIME% >>"%LOGFILE%"
@Echo ================================== >>"%LOGFILE%"
:: ========================================================================================
:: Configure Power Profile (High Performance)
POWERCFG /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >>"%LOGFILE%"

:: Disable the Network Selection popup, all networks default to Public
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff /f >>"%LOGFILE%"

:: Disable Cortana.  This has the added effect of changing Search on the Taskbar to icon-mode 
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >>"%LOGFILE%"

:: Disable OneDrive
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >>"%LOGFILE%"

:: Disable Microsoft Advertising (Suggested Apps i.e. Candy Crush Saga)
REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >>"%LOGFILE%"

:: Disable autorun Windows Defender
REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v SecurityHealth /f >>"%LOGFILE%"

:: Disable Windows Defender Antispyware
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >>"%LOGFILE%"

:: Disable Malicious Software Removal Tool (MSRT)
REG ADD HKLM\SOFTWARE\Policies\Microsoft\MRT /v DontOfferThroughWUAU /t REG_DWORD /d 1 /f >>"%LOGFILE%"

:: Disable Windows Error Reporting
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >>"%LOGFILE%"
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v DefaultConsent /t REG_DWORD /d 4 /f >>"%LOGFILE%"

:: Configure Windows Update to Current Branch for Business (CBB)
REG ADD HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings /v BranchReadinessLevel /t REG_DWORD /d 32 /f >>"%LOGFILE%"

:: Configure the default 'in-use' hours (10AM-2PM)
REG ADD HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings /v ActiveHoursStart /t REG_DWORD /d 10 /f >>"%LOGFILE%"
REG ADD HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings /v ActiveHoursEnd /t REG_DWORD /d 14 /f >>"%LOGFILE%"

:: Disable use of Preview Builds (because they don't belong in an Enterprize environment)
REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds /v AllowBuildPreview /t REG_DWORD /d 0 /f >>"%LOGFILE%"

:: Disable the first-run wizard in Windows Media Player
REG ADD HKLM\Software\Policies\Microsoft\WindowsMediaPlayer /v GroupPrivacyAcceptance /t REG_DWORD /d 1 /f >>"%LOGFILE%"

:: Configure the Default User Avatar
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer /v UseDefaultTile /t REG_DWORD /d 1 /f >>"%LOGFILE%"

:: Enable Remote Desktop in-bound (RDP)
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >>"%LOGFILE%"

:: Allow out-bound RDP connection to older/unpatched Operating Systems (CredSSP)
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters /v AllowEncryptionOracle /t REG_DWORD /d 2 /f >>"%LOGFILE%"

:: Approve default IE add-ons
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext /v IgnoreFrameApprovalCheck /t REG_DWORD /d 1 /f >>"%LOGFILE%"
REG ADD HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\Ext /v IgnoreFrameApprovalCheck /t REG_DWORD /d 1 /f >>"%LOGFILE%"

:: Configure the default Powershell Execution Policy
REG ADD HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d RemoteSigned /f >>"%LOGFILE%"

:: Hide folders in File Explorer (Pictures, Videos, Music, 3D Objects)
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >>"%LOGFILE%"
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >>"%LOGFILE%"
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >>"%LOGFILE%"
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >>"%LOGFILE%"

:: Disable XBox Services
for %%X in (XboxGipSvc XblAuthManager XblGameSave XboxNetApiSvc xbgm) do (sc config "%%X" start= disabled >>"%LOGFILE%")

:: Check if we are running in a Task Sequence
IF EXIST "%~dp0TestForTS.vbs" (CALL cscript TestForTS.vbs && SET TS=%ErrorLevel% && DEL /Q "%~dp0TestForTS.vbs")
IF %TS% EQU 0 (@Echo Not in Task Sequence)
:: ========================================================================================

:THEEND
@Echo The image has been applied and specialized for this machine
@Echo System will now reboot into the OOBE phase
@Echo.
TIMEOUT /T 15
