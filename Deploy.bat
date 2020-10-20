@echo off
cd %~dp0
set "_title=Checksum"
set "_version=3.0a"
set "_date=20201020"
set "_author=lxvs"
set "_email=lllxvs@gmail.com"
set "_target=%USERPROFILE%\checksum.bat"
title %_title% Deployment %_version%
echo.
echo.  - UPDATE LOG -
echo.
echo.  ^| Get MD5 v3.0    20201015
echo.  ^|  - Deploy to user's folder now.
echo.  ^|  - Codes improved.
echo.  ^|  
echo.  ^| Get MD5 v3.0a   20201020
echo.  ^|  - Fixed a bug that first 3 characters of lower case MD5 output was omitted.
echo.  ^|  - Considered the situation that checksum on a blank file.
echo.  ^|  
echo.  ^| Comming soon:
echo.  ^|  - Quiet mode ^(do not show the dialog and only copy MD5 output^).
echo.  ^|  - Imporve multi-file support.
echo.  ^|  - More algorithms.
echo.  ^|  
echo.  ^| by %_author% ^<%_email%^>
echo.
call:deltmp

:ModeSelect
echo.
echo.^> Please select work mode from below and press Enter.
echo.
echo.  ^| 1: Add Get MD5 ^(UPPER CASE OUTPUT^) to context menu ^(default^).
echo.  ^| 
echo.  ^| 2: Add Get MD5 ^(lower case output^) to context menu.
echo.  ^| 
echo.  ^| 0: Entirely remove Get MD5 context menu and relative files.
echo.  ^| 
echo.  ^| Q: Quit.
echo.
set /p=$ <nul
set /p mode=
if "%mode%"=="" (set mode=1)

if %mode%==1 (goto Mode1)
if %mode%==2 (goto Mode2)
if %mode%==0 (goto Mode0)
if %mode%==Q (exit)
if %mode%==q (exit)
cls
echo.
echo.^> Unexpected value input.
echo.
goto ModeSelect

:Mode1
:Mode2
echo.
echo.^> Adding [Get MD5] to right-click menu...
REG ADD HKCR\*\shell\checksum /ve /d "Get MD5" /f >nul 2>&1 || call:err 560
REG ADD HKCR\*\shell\checksum\command /ve /d "\"%_target%\" \"%%1\"" /f >nul 2>&1 || call:err 570
echo.
echo.^> Writting the batch file to %_target%...
echo.@echo off>deploy.tmp || call:err 610
attrib +h deploy.tmp
echo title %_title% %_version%>>deploy.tmp
echo rem>>deploy.tmp
echo rem %_title% %_version% %_date%>>deploy.tmp
echo rem>>deploy.tmp
echo rem by %_author% ^<%_email%^>>>deploy.tmp
echo rem>>deploy.tmp
echo if "%%~1" EQU "" ^(exit^)>>deploy.tmp
echo if "%%~z1" EQU "0" ^(exit^)>>deploy.tmp
echo echo %%~1>>deploy.tmp
echo echo.>>deploy.tmp
echo FOR /F "skip=1 delims=" %%%%i IN ^('CertUtil -hashfile %%1 md5'^) DO (>>deploy.tmp
echo.    set mout=%%%%i>>deploy.tmp
echo.    goto End>>deploy.tmp
echo ^)>>deploy.tmp
echo ^:End>>deploy.tmp

if %mode%==2 (goto mode_lowercase)
echo FOR /F "skip=2 delims=" %%%%I in ^('tree "\%%mout%%"'^) do if not defined moutupper set "moutupper=%%%%~I">>deploy.tmp
echo set "mout=%%moutupper:~3%%">>deploy.tmp

:mode_lowercase
echo echo %%mout%%>>deploy.tmp
echo echo.>>deploy.tmp
echo echo ^| set /p=%%mout%%^| clip>>deploy.tmp
echo echo MD5 has been copied to clipboard.>>deploy.tmp
echo echo.>>deploy.tmp
echo pause>>deploy.tmp
del /f /q %_target% >nul 2>&1
del /ah /f /q %_target% >nul 2>&1
echo f |xcopy deploy.tmp %_target% /h /y >nul 2>&1 || call:err 920
attrib +r +h %_target%
call:DelTmp
goto Finished

:Mode0
REG DELETE HKCR\*\shell\checksum /f >nul 2>&1 || call:err 1030
del /f /q %_target% >nul 2>&1
del /ah /f /q %_target% >nul 2>&1
if exist %_target% (call:err 1020)
goto Finished_0

:Finished
echo. 
echo.^> Congratulations! Deployment is finished, now you should see an [Get MD5] item on the right-click menu of a file.
echo.
set /p=^> <nul
pause
exit

:Finished_0
echo. 
echo.^> Removed successfully!
echo.
set /p=^> <nul
pause
exit

:err
call:deltmp
cls
echo.
echo.^> Error code: %1
echo.
echo.^> Please run this script as administrator.
echo.
set /p=^> <nul
pause
exit

:DelTmp
del /f /q deploy.tmp >nul 2>&1
del /ah /f /q deploy.tmp >nul 2>&1
goto:eof
