@echo off
cd %~dp0
set "_title=Get MD5"
set "_version=2.0"
set "_date=20201012"
set "_author=lxvs"
set "_email=lllxvs@gmail.com"
title %_title% Deployment %_version%
echo.
echo.  - UPDATE LOG -
echo.
echo.  ^| Get MD5 v1.1 20200819
echo.  ^|  
echo.  ^|   - Now MD5 output is in uppercase.
echo.  ^|   - Removed double quote in the first line output.
echo.  ^|   - Removed spaces of the output.
echo.  ^|   - Added execution feedback.
echo.  ^|  
echo.  ^| Get MD5 v1.2 20200919
echo.  ^|  
echo.  ^|   - Set MD5.bat to hidden.
echo.  ^|   - Now will delete the old MD5.bat before copying.
echo.  ^|   - Added a title.
echo.  ^|  
echo.  ^| Get MD5 v2.0 20201012
echo.  ^|   
echo.  ^|   - Added mode selection function.
echo.  ^|   - Added undeployment function.
echo.  ^|   - Added capital toggle function.
echo.  ^|   - Fixes a bug that happens when there is no argument.
echo.  ^|   - Look ^& feel improvements.
echo.  ^|   - Minor bug fixes.
echo.  ^|  
echo.  ^| by %_author%
echo.  ^|  
echo.  ^| %_email%
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
echo.^> Writting the batch file to C:\MD5.bat ...
echo.@echo off>getmd5tmp.bat || call:err 70
attrib +h getmd5tmp.bat
echo title %_title% %_version%>>getmd5tmp.bat
echo rem>>getmd5tmp.bat
echo rem %_title% %_version% %_date%>>getmd5tmp.bat
echo rem>>getmd5tmp.bat
echo rem by %_author% ^<%_email%^>>>getmd5tmp.bat
echo rem>>getmd5tmp.bat
echo if "%%~1" EQU "" ^(exit^)>>getmd5tmp.bat
echo echo %%~1>>getmd5tmp.bat
echo echo.>>getmd5tmp.bat
echo FOR /F "skip=1 delims=" %%%%i IN ^('CertUtil -hashfile %%1 md5'^) DO (>>getmd5tmp.bat
echo.    set mout=%%%%i>>getmd5tmp.bat
echo.    goto End>>getmd5tmp.bat
echo ^)>>getmd5tmp.bat
echo ^:End>>getmd5tmp.bat

if %mode%==2 (goto mode_lowercase)
echo FOR /F "skip=2 delims=" %%%%I in ^('tree "\%%mout%%"'^) do if not defined moutupper set "moutupper=%%%%~I">>getmd5tmp.bat
echo set "mout=%%moutupper%%">>getmd5tmp.bat

:mode_lowercase
echo set "mout=%%mout:~3%%">>getmd5tmp.bat
echo echo %%mout%%>>getmd5tmp.bat
echo echo.>>getmd5tmp.bat
echo echo ^| set /p=%%mout%%^| clip>>getmd5tmp.bat
echo echo MD5 has been copied to clipboard.>>getmd5tmp.bat
echo echo.>>getmd5tmp.bat
echo pause>>getmd5tmp.bat
del /f /q C:\MD5.bat >nul 2>&1
del /ah /f /q C:\MD5.bat >nul 2>&1
echo f |xcopy getmd5tmp.bat C:\MD5.bat /h /y >nul 2>&1 || call:err 1010
attrib +r +h C:\MD5.bat
del /f /q getmd5tmp.bat >nul 2>&1
del /ah /f /q getmd5tmp.bat >nul 2>&1

echo.
echo.^> Adding [Get MD5] to right-click menu...
echo Windows Registry Editor Version 5.00>getmd5tmp.reg || call:err 1090
attrib +h getmd5tmp.reg
echo [HKEY_CLASSES_ROOT\*\shell\getmd5]>>getmd5tmp.reg
echo @="Get MD5">>getmd5tmp.reg
echo [HKEY_CLASSES_ROOT\*\shell\getmd5\command]>>getmd5tmp.reg
echo @="C:\\MD5.bat \"%%1\"">>getmd5tmp.reg
regedit /s getmd5tmp.reg || call:err 1150
del /f /q getmd5tmp.reg >nul 2>&1
del /ah /f /q getmd5tmp.reg >nul 2>&1
goto Finished

:Mode0
del /f /q C:\MD5.bat >nul 2>&1
del /ah /f /q C:\MD5.bat >nul 2>&1
if exist C:\MD5.bat (call:err 1241)
echo Windows Registry Editor Version 5.00>getmd5tmp0.reg || call:err 1240
attrib +h getmd5tmp0.reg
echo [-HKEY_CLASSES_ROOT\*\shell\getmd5]>>getmd5tmp0.reg
regedit /s getmd5tmp0.reg || call:err 1270
del /f /q getmd5tmp0.reg >nul 2>&1
del /ah /f /q getmd5tmp0.reg >nul 2>&1
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
echo.^> If you did run as administer, please contact %_email% for support!
echo.
set /p=^> <nul
pause
exit

:DelTmp
del /f /q getmd5tmp.bat >nul 2>&1
del /f /q getmd5tmp.reg >nul 2>&1
del /f /q getmd5tmp0.reg >nul 2>&1
del /ah /f /q getmd5tmp.bat >nul 2>&1
del /ah /f /q getmd5tmp.reg >nul 2>&1
del /ah /f /q getmd5tmp0.reg >nul 2>&1
goto:eof
