@Echo Off

:BEGIN
SET LOGFILE="%~dp0SetupComplete.log"
@Echo Begin SetupComplete >>%LOGFILE%
@Echo %DATE% %TIME% >>%LOGFILE%
@Echo =============================================================== >>%LOGFILE%

SET XTASK=Disable Cortana
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable OneDrive
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable the Network Selection
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable Microsoft Advertising
REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable Windows Defender autorun
REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v SecurityHealth /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable Windows Defender Antispyware
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable Malicious Software Removal Tool
REG ADD HKLM\SOFTWARE\Policies\Microsoft\MRT /v DontOfferThroughWUAU /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Configure Windows Error Reporting consent
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v DefaultConsent /t REG_DWORD /d 4 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable Windows Error Reporting
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Configure WU to Semi-Annual Channel
REG ADD HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings /v BranchReadinessLevel /t REG_DWORD /d 32 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Configure 'in-use' hours
REG ADD HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings /v ActiveHoursStart /t REG_DWORD /d 10 /f >NUL
@Echo %ERRORLEVEL%    %XTASK%: Start >>%LOGFILE%
REG ADD HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings /v ActiveHoursEnd /t REG_DWORD /d 14 /f >NUL
@Echo %ERRORLEVEL%    %XTASK%: End >>%LOGFILE%

SET XTASK=Disable use of Preview Builds
REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds /v AllowBuildPreview /t REG_DWORD /d 0 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable Media Player first-run Wizard
REG ADD HKLM\Software\Policies\Microsoft\WindowsMediaPlayer /v GroupPrivacyAcceptance /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Configure User Avatar
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer /v UseDefaultTile /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Enable in-bound RDP
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Enable out-bound RDP (CredSSP)
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters /v AllowEncryptionOracle /t REG_DWORD /d 2 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Disable Edge desktop shortcut creation
REG ADD HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Approve installed IE add-ons
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext /v IgnoreFrameApprovalCheck /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% (64-bit) >>%LOGFILE%
REG ADD HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\Ext /v IgnoreFrameApprovalCheck /t REG_DWORD /d 1 /f >NUL
@Echo %ERRORLEVEL%    %XTASK% (32-bit) >>%LOGFILE%

SET XTASK=Hide folders in File Explorer
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >NUL
@Echo %ERRORLEVEL%    %XTASK%: Pictures >>%LOGFILE%
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >NUL
@Echo %ERRORLEVEL%    %XTASK%: Videos >>%LOGFILE%
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >NUL
@Echo %ERRORLEVEL%    %XTASK%: Music >>%LOGFILE%
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >NUL
@Echo %ERRORLEVEL%    %XTASK%: 3D Objects >>%LOGFILE%

SET XTASK=Configure Powershell Execution Policy: RemoteSigned
REG ADD HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d RemoteSigned /f >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

SET XTASK=Configure Power Profile: High Performance
POWERCFG /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

:THEEND
@Echo =============================================================== >>%LOGFILE%
@Echo %DATE% %TIME% >>%LOGFILE%

