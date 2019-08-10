@Echo Off

:BEGIN
SET LOGFILE="%~dp0SetupComplete.log"
@Echo Begin SetupComplete >%LOGFILE%
@Echo %DATE% %TIME% >>%LOGFILE%
@Echo =============================================================== >>%LOGFILE%
@Echo. >>%LOGFILE%

:: The real magic is done by SCCM
:: This is just an example of what you could do here

SET XTASK=Configure Power Profile: High Performance
POWERCFG /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >NUL
@Echo %ERRORLEVEL%    %XTASK% >>%LOGFILE%

:THEEND
@Echo. >>%LOGFILE%
@Echo =============================================================== >>%LOGFILE%
@Echo %DATE% %TIME% >>%LOGFILE%

