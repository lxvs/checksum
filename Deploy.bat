@echo off
cd %~dp0
set "_title=Checksum"
set "_version=4.0b"
set "_date=20201105"
set "_author=lxvs"
set "_email=lllxvs@gmail.com"
set "_target=%USERPROFILE%\checksum.bat"
title %_title% Deployment %_version%
:init
echo.
echo.  - Release Notes -
echo.
echo.  ^| checksum 4.0a   20201027
echo.  ^|  - Added more algorithms: MD4, MD2, SHA1, SHA256, SHA384, SHA512.
echo.  ^|  
echo.  ^| checksum 4.0b   20201105
echo.  ^|  - Added multi-algorithm deployment support.
echo.  ^|  
echo.  ^| Comming soon:
echo.  ^|  - Cascaded context menu.
echo.  ^|  - Quiet mode ^(do not show the dialog and only copy MD5 output^).
echo.  ^|  - Imporve multi-file support.
echo.  ^|  
echo.  ^| by %_author% ^<%_email%^>
echo.
call:deltmp
:ModeDisp
echo.
echo.^> Please choose one algorithm ^(input the numbering^):
echo.
echo.  ^| 1   MD5
echo.  ^| 
echo.  ^| 2   MD4
echo.  ^| 
echo.  ^| 4   MD2
echo.  ^| 
echo.  ^| 8   SHA1
echo.  ^| 
echo.  ^| 16  SHA256
echo.  ^| 
echo.  ^| 32  SHA384
echo.  ^| 
echo.  ^| 64  SHA512
echo.  ^| 
REM echo.  ^| 128 Cascaded context menu
REM echo.  ^| 
echo.  ^| 0   Uninstall
echo.
echo.^> You can choose multiple items by adding the numbering. For example, input 1+8+128 or 137 for creating a cascaded menu containing MD5 and SHA1. 
:ModeInput
echo.
set /p=$ <nul
set mode=
set /p mode=
if "%mode%"=="" (goto Unexp)
if %mode%==0 (goto mode0)
if %mode%==q (exit)
if %mode%==quit (exit)
if %mode%==exit (exit)
set confirmed=0
if %mode:~-1%==y (
    set mode=%mode:~,-1%
    set confirmed=1
)
if "%mode%" NEQ "" (goto ModeParse)
:Unexp
echo.
echo.^> Unexpected value input.
goto ModeInput
:ModeParse
set /a mode=%mode% >nul 2>&1 || goto Unexp
if %mode%==0 (goto Unexp)
if %mode%==128 (goto Unexp)
set /a alg0=%mode%/1%%2
set /a alg1=%mode%/2%%2
set /a alg2=%mode%/4%%2
set /a alg3=%mode%/8%%2
set /a alg4=%mode%/16%%2
set /a alg5=%mode%/32%%2
set /a alg6=%mode%/64%%2
set /a CCMENU=%mode%/128%%2
echo.
set /p=^> You choosed: <nul
set alg=
if %alg0% EQU 1 (set alg=%alg%MD5 )
if %alg1% EQU 1 (set alg=%alg%MD4 )
if %alg2% EQU 1 (set alg=%alg%MD2 )
if %alg3% EQU 1 (set alg=%alg%SHA1 )
if %alg4% EQU 1 (set alg=%alg%SHA256 )
if %alg5% EQU 1 (set alg=%alg%SHA384 )
if %alg6% EQU 1 (set alg=%alg%SHA512 )
set /p=%alg%<nul
if %ccmenu% EQU 1 (set /p=and cascaded menu, <nul)
set /p=right? ^(Y^/N^): <nul
if %confirmed%==1 (
    set confirm=Y
    set /p=Y<nul
    echo.
) else (
    set confirm=
    set /p confirm=
)
if "%confirm%" EQU "" (set confirm=N)
if %confirm% EQU y (set confirm=Y)
if %confirm% NEQ Y (goto modedisp)
echo.
echo.^> Adding checksum to context menu...
call:delReg
rem set /a algC=%alg0%+%alg1%+%alg2%+%alg3%+%alg4%+%alg5%+%alg6%
if %ccmenu% EQU 1 (
    echo.
    echo.^> Do not choose cascaded context menu ^(128^) for now, which is in development and coming in 4.1 version. Apologies for the inconvenience.
    echo.
    set /p=^> <nul
    pause
    cls
    goto init
) else (
    for %%i in (%alg%) do (
        REG ADD HKCR\*\shell\checksum_%%i /ve /d "Checksum - "%%i /f >nul 2>&1 || call:err 560
        REG ADD HKCR\*\shell\checksum_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i" /f >nul 2>&1 || call:err 570
    )
)
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
echo FOR /F "skip=1 delims=" %%%%i IN ^('CertUtil -hashfile %%1 %%2'^) DO (>>deploy.tmp
echo.    set mout=%%%%i>>deploy.tmp
echo.    goto End>>deploy.tmp
echo ^)>>deploy.tmp
echo ^:End>>deploy.tmp
rem if %LCase%==1 (goto mode_lowercase)
echo FOR /F "skip=2 delims=" %%%%I in ^('tree "\%%mout%%"'^) do if not defined moutupper set "moutupper=%%%%~I">>deploy.tmp
echo set "mout=%%moutupper:~3%%">>deploy.tmp

:mode_lowercase
echo set /p=%%2: ^< nul>>deploy.tmp
echo echo %%mout%%>>deploy.tmp
echo echo.>>deploy.tmp
echo echo ^| set /p=%%mout%%^| clip>>deploy.tmp
echo echo Checksum has been copied to clipboard.>>deploy.tmp
echo echo.>>deploy.tmp
echo pause>>deploy.tmp
del /f /q %_target% >nul 2>&1
del /ah /f /q %_target% >nul 2>&1
echo f |xcopy deploy.tmp %_target% /h /y >nul 2>&1 || call:err 920
attrib +r +h %_target%
call:DelTmp
goto Finished

:Mode0
call:delreg
del /f /q %_target% >nul 2>&1
del /ah /f /q %_target% >nul 2>&1
if exist %_target% (call:err 1020)
goto Finished_0

:Finished
echo. 
echo.^> Deployment is finished.
echo.
set /p=^> <nul
pause
exit

:Finished_0
echo. 
echo.^> Uninstallation has finished.
echo. 
echo.^> If checksum items still exist in context menu, please run this script as adminitrator and unistall again.
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

:DelReg
REG DELETE HKCR\*\shell\checksum /f >nul 2>&1
REG DELETE HKCR\*\shell\checksum_MD5 /f >nul 2>&1
REG DELETE HKCR\*\shell\checksum_MD4 /f >nul 2>&1
REG DELETE HKCR\*\shell\checksum_MD2 /f >nul 2>&1
REG DELETE HKCR\*\shell\checksum_SHA1 /f >nul 2>&1
REG DELETE HKCR\*\shell\checksum_SHA256 /f >nul 2>&1
REG DELETE HKCR\*\shell\checksum_SHA384 /f >nul 2>&1
REG DELETE HKCR\*\shell\checksum_SHA512 /f >nul 2>&1
goto:eof
