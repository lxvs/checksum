@echo off
setlocal enableExtensions enableDelayedExpansion
pushd %~dp0
set "rev=5.0.0"
set "lastupdt=2021-06-22"
set "_title=Checksum"
set "_target=%USERPROFILE%\checksum.bat"
set "_icon=%SystemRoot%\System32\SHELL32.dll,-23"
set "_link=https://lxvs.net/checksum"
set "RegiPath=HKCU\SOFTWARE\Classes\*\shell\checksum"
title %_title% v%rev% Deployment
call:logo
call:Deltmp

:modeDisp
@echo;
@echo Please choose algorithms ^& options
@echo;
@echo   ^| 1     MD2
@echo   ^| 2     MD4
@echo   ^| 4     MD5
@echo   ^| 8     SHA1
@echo   ^| 16    SHA256
@echo   ^| 32    SHA384
@echo   ^| 64    SHA512
@echo   ^| 128   Cascaded context menu
@echo   ^| 256   Also add lowercase output mode
@echo   ^| 512   Also add quietly-copy-to-clipboard mode
@echo   ^| 1024  Also add output-to-file mode
@echo   ^| 4096  Disable colorful output.
@echo   ^| 0     Uninstall
@echo;
@echo You can choose multiple items by adding the numbering. For example,
@echo;
@echo   ^| 4+16         MD5 and SHA256, UPPERCASE output only.
@echo   ^| 4+16L        MD5 and SHA256, lowercase output only.
@echo   ^| 4+16+256     MD5 and SHA256, UPPERCASE and lowercase output.
@echo;
@echo 16+512+1024 ^(1552^) is recommended.
goto modeInput

:unexp
@echo;
@echo Unexpected value input.

:modeInput
set /p=$ <nul
set "mod="
set /p "mod="
if "%mod%"=="" goto modeinput
if "%mod%"=="0" goto uninstall
if /i "%mod%"=="q" exit /b 0
if /i "%mod%"=="quit" exit /b 0
if /i "%mod%"=="exit" exit /b 0
set "cfmd="
set "cfmd2="
set "lcase="
if /i "%mod:~-1%"=="Y" (
    set "mod=%mod:~0,-1%"
    set cfmd=1
)
if "%cfmd%"=="1" if /i "%mod:~-1%"=="Y" (
    set "mod=%mod:~0,-1%"
    set cfmd2=1
)
if /i "%mod:~-1%"=="L" (
    set "mod=%mod:~0,-1%"
    set lcase=1
)
set /a mod=%mod% 1>nul 2>&1 || goto unexp
if "%mod%"=="0" goto unexp
set /a "alg0=mod/1%%2"
set /a "alg1=mod/2%%2"
set /a "alg2=mod/4%%2"
set /a "alg3=mod/8%%2"
set /a "alg4=mod/16%%2"
set /a "alg5=mod/32%%2"
set /a "alg6=mod/64%%2"
set /a "ccmn=mod/128%%2"
set /a "modl=mod/256%%2"
set /a "modq=mod/512%%2"
set /a "modf=mod/1024%%2"
set /a "dcol=mod/4096%%2"

set /a "algs=alg0+alg1+alg2+alg3+alg4+alg5+alg6"
if %algs% LEQ 0 goto unexp
set /p=You choosed: <nul

set "alg="
if %alg0% EQU 1 set "alg=%alg% MD2"
if %alg1% EQU 1 set "alg=%alg% MD4"
if %alg2% EQU 1 set "alg=%alg% MD5"
if %alg3% EQU 1 set "alg=%alg% SHA1"
if %alg4% EQU 1 set "alg=%alg% SHA256"
if %alg5% EQU 1 set "alg=%alg% SHA384"
if %alg6% EQU 1 set "alg=%alg% SHA512"

set /p=%alg%<nul
if %ccmn% EQU 1 set /p=, cascaded menu<nul
if %modl% EQU 1 set /p=, lowercase mode<nul
if %modq% EQU 1 set /p=, quiet mode<nul
if %modf% EQU 1 set /p=, output-to-file mode<nul
if %dcol% EQU 1 set /p=, colorful output disabled<nul
set /p=, right? ^(Y/N^): <nul
if "%cfmd%" == "1" (
    set "confirm=Y"
    set /p=Y<nul
    @echo;
) else (
    set "confirm="
    set /p "confirm="
)
if /i "%confirm%" NEQ "Y" goto modeInput
if %dcol% EQU 1 (
    set "algPre="
    set "fnmPre="
    set "outPre="
    set "errPre="
    set "sucPre="
    set "suf="
) else (
    @set "algPre=[92m"
    @set "fnmPre=[92m"
    @set "outPre=[93m"
    @set "errPre=[93;101m"
    @set "sucPre=[92m"
    @set "suf=[0m"
)
@echo Uninstalling previous installations ^(if any^)...
call:Uninstall "preins"
@echo Adding checksum to context menu...
call:delReg
if %ccmn% EQU 1 (goto ccmn1) else goto ccmn0

:ccmn1
REG ADD %RegiPath% /v "MUIVerb" /d "Checksum (&Q)" /f 1>nul
REG ADD %RegiPath% /v "Icon" /d "%_icon%" /f 1>nul
REG ADD %RegiPath% /v "SubCommands"  /f 1>nul
REG ADD %RegiPath%\shell /f 1>nul

set /a "index=0"
set /a "scnum=0"
set "sckey="
for %%i in (%alg%) do (
    set /a "index+=1"
    set /a "scnum=index"
    if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
    if !scnum! EQU 10 set "sckey= (&0)"
    REG ADD %RegiPath%\shell\a_%%i /ve /d "%%i!sckey!" /f 1>nul
    REG ADD %RegiPath%\shell\a_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i" /f 1>nul
    if %modf% EQU 1 (
        set /a "scnum+=algs"
        if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        if !scnum! EQU 10 set "sckey= (&0)"
        REG ADD %RegiPath%\shell\f_%%i /ve /d "To file - %%i!sckey!" /f 1>nul
        REG ADD %RegiPath%\shell\f_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i F" /f 1>nul
    )
    if %modl% EQU 1 (
        set /a "scnum+=algs"
        if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        if !scnum! EQU 10 set "sckey= (&0)"
        REG ADD %RegiPath%\shell\l_%%i /ve /d "Lowercase - %%i!sckey!" /f 1>nul
        REG ADD %RegiPath%\shell\l_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i L" /f 1>nul
    )
    if %modq% EQU 1 (
        set /a "scnum+=algs"
        if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        if !scnum! EQU 10 set "sckey= (&0)"
        REG ADD %RegiPath%\shell\q_%%i /ve /d "To clipboard - %%i!sckey!" /f 1>nul
        REG ADD %RegiPath%\shell\q_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i Q" /f 1>nul
    )
)
goto afterccmn

:ccmn0
set "scq=1"
set "scf=1"
set "scl=1"
set "sck=1"
for %%i in (%alg%) do (
    if "!scq!"=="1" (set "scq= (&Q)") else set "scq="
    REG ADD %RegiPath%a_%%i /ve /d "Checksum - %%i!scq!" /f 1>nul
    REG ADD %RegiPath%a_%%i /v "Icon" /d "%_icon%" /f 1>nul
    REG ADD %RegiPath%a_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i" /f 1>nul
    if %modf% EQU 1 (
        if "!scf!"=="1" (set "scf= (&F)") else set scf=
        REG ADD %RegiPath%f_%%i /ve /d "Checksum to file - %%i!scf!" /f 1>nul
        REG ADD %RegiPath%f_%%i /v "Icon" /d "%_icon%" /f 1>nul
        REG ADD %RegiPath%f_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i F" /f 1>nul
    )
    if %modl% EQU 1 (
        if "!scl!"=="1" (set "scl= (&L)") else set "scl="
        REG ADD %RegiPath%l_%%i /ve /d "Checksum lowercase - %%i!scl!" /f 1>nul
        REG ADD %RegiPath%l_%%i /v "Icon" /d "%_icon%" /f 1>nul
        REG ADD %RegiPath%l_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i L" /f 1>nul
    )
    if %modq% EQU 1 (
        if "!sck!"=="1" (set "sck= (&K)") else set sck=
        REG ADD %RegiPath%q_%%i /ve /d "Checksum to clipboard - %%i!sck!" /f 1>nul
        REG ADD %RegiPath%q_%%i /v "Icon" /d "%_icon%" /f 1>nul
        REG ADD %RegiPath%q_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i Q" /f 1>nul
    )
)
goto afterccmn

:afterccmn
@echo Writing called script...
setlocal disableDelayedExpansion
@(
echo @rem %_link%
echo @echo off
echo setlocal enableExtensions enableDelayedExpansion
echo title %_title% v%rev%
echo if "%%~1" == "" exit /b 1
echo if not exist "%%~1" ^(
echo     call:ChksmErr 1950 "file %%~1 does not exist."
echo     exit /b
echo ^)
echo if "%%~z1" == "0" ^(
echo     call:ChksmErr 1990 "file %%~1 is empty."
echo     exit /b
echo ^)
echo if not "%%3" == "" ^(
echo     set "_mode=%%3"
echo     set "_F=0"
echo     set "_L=0"
echo     set "_Q=0"
echo     set "len=0"
echo     goto parse
echo ^) else goto postparse
echo :parse
echo set "tran=!_mode:~%%len%%,1!"
echo set /a "len+=1"
echo if "!tran!" NEQ "" ^(
echo     if "!tran!"=="F" ^(
echo         set "_F=1"
echo         goto parse
echo     ^)
echo     if "!tran!"=="L" ^(
echo         set "_L=1"
echo         goto parse
echo     ^)
echo     if "!tran!"=="Q" ^(
echo         set "_Q=1"
echo         goto parse
echo     ^)
echo ^)
echo :postparse
echo set "fpath=%%~dp1"
echo set "fname=%%~nx1"
echo if not "%%_Q%%" == "1" if not "%%_F%%" == "1" @echo %%fpath:^^=^^^^%%%fnmpre%%%fname:^^=^^^^%%%suf%
echo set mout=
echo FOR /F "skip=1 delims=" %%%%i IN ^('CertUtil -hashfile %%1 %%2'^) do if not defined mout set mout=%%%%i
echo if /i "%%mout:~0,8%%"=="certutil" goto cuerr
if not "%lcase%" == "1" (
    echo if "%%_L%%"=="1" goto skipupper
    echo set moutupper=
    echo FOR /F "skip=2 delims=" %%%%I in ^('tree "\%%mout%%"'^) do if not defined moutupper set "moutupper=%%%%~I"
    echo set "mout=%%moutupper:~3%%"
    echo :skipupper
)
echo if "%%_F%%" == "1" goto fileoutput
echo @echo ^| set /p=%%mout%%^| clip
echo if "%%_Q%%" == "1" exit /b 0
echo set /p=%algpre%%%2%suf%: ^<nul
echo @echo %outpre%%%mout%%%suf%
echo @echo;
echo @echo Checksum has been copied to clipboard.
echo @echo;
echo pause
echo exit /b 0
echo :fileoutput
echo set "fnamef=%%~nx1"
echo set "fnamefR=%%fnamef:^=^^%%"
echo @echo %%fnamefR%%^>"%%fnamef%%_%%2.txt"
echo @echo %%2: %%mout%%^>^>"%%fnamef%%_%%2.txt"
echo exit /b 0
echo :cuerr
echo ^(certutil -hashfile %%1 %%2^) 1^>nul 2^>^&1
echo @echo %errpre%%%mout:~10%%%suf%
echo @echo;
echo pause
echo exit /b
echo :ChksmErr
echo @echo %errpre%Error^(%%1^): %%~2%suf%
echo @echo;
echo pause
echo exit /b %%1
)>deploy.tmp || (
    call:Err 1 "Cannot write to temporary directory."
    exit /b
)
attrib +h deploy.tmp
setlocal enableDelayedExpansion
del /f /q %_target% 1>nul 2>&1
del /ah /f /q %_target% 1>nul 2>&1
@echo f | xcopy deploy.tmp %_target% /h /y 1>nul 2>&1 || (
    call:Err 2 "Cannot copy file to %_target%"
    exit /b
)
attrib +r +h %_target%
call:DelTmp
@echo %sucPre%Deployment is finished.%suf%
if "%cfmd2%" NEQ "1" pause
exit /b 0

:uninstall
call:Delreg
del /f /q %_target% 1>nul 2>&1
del /ah /f /q %_target% 1>nul 2>&1
if "%~1" == "preins" exit /b
if exist %_target% (
    call:Err 3 "Failed to delete %_target%"
    exit /b
)
@echo %sucpre%Uninstallation has finished.%suf%
pause
exit /b

:Err
call:Deltmp
>&2 echo;
>&2 echo %errpre%ERROR%suf% ^(%1^)
>&2 if "%~2" NEQ "" echo %~2
>&2 echo;
pause
exit /b %1

:DelTmp
del /f /q deploy.tmp 1>nul 2>&1
del /ah /f /q deploy.tmp 1>nul 2>&1
exit /b 0

:DelReg
REG DELETE %RegiPath% /f 1>nul 2>&1
for %%i in (MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512) do (
    REG DELETE %RegiPath%_%%i /f 1>nul 2>&1
    REG DELETE %RegiPath%a_%%i /f 1>nul 2>&1
    REG DELETE %RegiPath%c_%%i /f 1>nul 2>&1
    REG DELETE %RegiPath%f_%%i /f 1>nul 2>&1
    REG DELETE %RegiPath%l_%%i /f 1>nul 2>&1
    REG DELETE %RegiPath%q_%%i /f 1>nul 2>&1
)
exit /b 0

:logo
@echo;
@echo     %_title% v%rev%
@echo     %_link%
@echo     Last updated: %lastupdt%
@echo;
exit /b
