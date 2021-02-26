@echo off & setlocal
cd %~dp0
set "_title=Checksum"
set "_version=4.4.2"
set "_target=%USERPROFILE%\checksum.bat"
set "_icon=%SystemRoot%\System32\SHELL32.dll,-23"
set "_crinfo=https://github.com/lxvs/checksum"
title %_title% Deployment %_version%
echo ^> Release Notes won't show here since 4.4.1.
echo ^> Please see CHANGELOG.
call:deltmp
:ModeDisp
echo;
echo ^> Please choose one algorithm ^(input the numbering^):
echo;
echo   ^| 1     MD2
echo   ^| 2     MD4
echo   ^| 4     MD5
echo   ^| 8     SHA1
echo   ^| 16    SHA256
echo   ^| 32    SHA384
echo   ^| 64    SHA512
echo   ^| 128   Cascaded context menu
echo   ^| 256   Also add lowercase output mode
echo   ^| 512   Also add quietly-copy-to-clipboard mode
echo   ^| 1024  Also add output-to-file mode
echo   ^| 0     Uninstall
echo;
echo ^> You can choose multiple items by adding the numbering. For example,
echo;
echo   ^| 4+8+128     MD5 and SHA1, in a cascaded menu, UPPERCASE output only.
echo   ^| 4+8+128L    MD5 and SHA1, in a cascaded menu, lowercase output only.
echo   ^| 4+8+128+256 MD5 and SHA1, in a cascaded menu, UPPERCASE and lowercase output.
goto modeinput
:Unexp
echo;
echo ^> Unexpected value input.
:ModeInput
echo;
set /p=$ <nul
set mod=
set /p mod=
if "%mod%"=="" goto modeinput
if "%mod%"=="0" goto uninstall
if /i "%mod%"=="q" goto:eof
if /i "%mod%"=="quit" goto:eof
if /i "%mod%"=="exit" goto:eof
set cfmd=
set cfmd2=
set lcase=
if /i "%mod:~-1%"=="Y" (set "mod=%mod:~,-1%" & set cfmd=1)
if "%cfmd%"=="1" if /i "%mod:~-1%"=="Y" (set "mod=%mod:~,-1%" & set cfmd2=1)
if /i "%mod:~-1%"=="L" (set "mod=%mod:~,-1%" & set lcase=1)
set /a mod=%mod% >nul 2>&1 || goto Unexp
if "%mod%"=="0" goto Unexp
set /a alg0=mod/1%%2
set /a alg1=mod/2%%2
set /a alg2=mod/4%%2
set /a alg3=mod/8%%2
set /a alg4=mod/16%%2
set /a alg5=mod/32%%2
set /a alg6=mod/64%%2
set /a ccmn=mod/128%%2
set /a modl=mod/256%%2
set /a modq=mod/512%%2
set /a modf=mod/1024%%2
set /a algs=alg0+alg1+alg2+alg3+alg4+alg5+alg6
if "%algs%"=="0" goto unexp
echo;
set /p=^> You choosed: <nul
set alg=
if "%alg0%"=="1" set "alg=%alg% MD2"
if "%alg1%"=="1" set "alg=%alg% MD4"
if "%alg2%"=="1" set "alg=%alg% MD5"
if "%alg3%"=="1" set "alg=%alg% SHA1"
if "%alg4%"=="1" set "alg=%alg% SHA256"
if "%alg5%"=="1" set "alg=%alg% SHA384"
if "%alg6%"=="1" set "alg=%alg% SHA512"
set /p=%alg%<nul
if "%ccmn%"=="1" set /p=, cascaded menu<nul
if "%modl%"=="1" set /p=, lowercase mode<nul
if "%modq%"=="1" set /p=, quiet mode<nul
if "%modf%"=="1" set /p=, output-to-file mode<nul
set /p=, right? ^(Y^/N^): <nul
if "%cfmd%"=="1" (
    set confirm=Y
    set /p=Y<nul
    echo;
) else (
    set confirm=
    set /p confirm=
)
if /i "%confirm%" NEQ "Y" cls & goto modedisp
echo;
echo ^> Adding checksum to context menu...
call:delReg
if "%ccmn%"=="1" (goto ccmn1) else goto ccmn0
:ccmn1
REG ADD HKCR\*\shell\checksum /v "MUIVerb" /d "Checksum (&Q)" /f >nul 2>&1 || ((call:err 1250) & goto:eof)
REG ADD HKCR\*\shell\checksum /v "Icon" /d "%_icon%" /f >nul 2>&1 || ((call:err 1252) & goto:eof)
REG ADD HKCR\*\shell\checksum /v "SubCommands"  /f >nul 2>&1 || ((call:err 1260) & goto:eof)
REG ADD HKCR\*\shell\checksum\shell /f >nul 2>&1 || ((call:err 1270) & goto:eof)
SETLOCAL ENABLEDELAYEDEXPANSION
set "index=0"
set "scnum=0"
set "sckey="
for %%i in (%alg%) do (
    set /a index+=1
    set /a scnum=index
    if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
    if !scnum! EQU 10 set "sckey= (&0)"
    REG ADD HKCR\*\shell\checksum\shell\a_%%i /ve /d "%%i!sckey!" /f >nul 2>&1 || ((call:err 1290) & goto:eof)
    REG ADD HKCR\*\shell\checksum\shell\a_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i" /f >nul 2>&1 || ((call:err 1300) & goto:eof)
    if "%modf%"=="1" (
        set /a scnum+=algs
        if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        if !scnum! EQU 10 set "sckey= (&0)"
        REG ADD HKCR\*\shell\checksum\shell\f_%%i /ve /d "To file - %%i!sckey!" /f >nul 2>&1 || ((call:err 1110) & goto:eof)
        REG ADD HKCR\*\shell\checksum\shell\f_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i F" /f >nul 2>&1 || ((call:err 1120) & goto:eof)
    )
    if "%modl%"=="1" (
        set /a scnum+=algs
        if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        if !scnum! EQU 10 set "sckey= (&0)"
        REG ADD HKCR\*\shell\checksum\shell\l_%%i /ve /d "Lowercase - %%i!sckey!" /f >nul 2>&1 || ((call:err 1150) & goto:eof)
        REG ADD HKCR\*\shell\checksum\shell\l_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i L" /f >nul 2>&1 || ((call:err 1160) & goto:eof)
    )
    if "%modq%"=="1" (
        set /a scnum+=algs
        if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        if !scnum! EQU 10 set "sckey= (&0)"
        REG ADD HKCR\*\shell\checksum\shell\q_%%i /ve /d "To clipboard - %%i!sckey!" /f >nul 2>&1 || ((call:err 1190) & goto:eof)
        REG ADD HKCR\*\shell\checksum\shell\q_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i Q" /f >nul 2>&1 || ((call:err 1200) & goto:eof)
    )
)
SETLOCAL DISABLEDELAYEDEXPANSION
goto afterccmn
:ccmn0
SETLOCAL ENABLEDELAYEDEXPANSION
set "scq=1" & set "scf=1" & set "scl=1" & set "sck=1"
for %%i in (%alg%) do (
    if "!scq!"=="1" (set "scq= (&Q)") else set scq=
    REG ADD HKCR\*\shell\checksuma_%%i /ve /d "Checksum - %%i!scq!" /f >nul 2>&1 || ((call:err 560) & goto:eof)
    REG ADD HKCR\*\shell\checksuma_%%i /v "Icon" /d "%_icon%" /f >nul 2>&1 || ((call:err 1330) & goto:eof)
    REG ADD HKCR\*\shell\checksuma_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i" /f >nul 2>&1 || ((call:err 570) & goto:eof)
    if "%modf%"=="1" (
        if "!scf!"=="1" (set "scf= (&F)") else set scf=
        REG ADD HKCR\*\shell\checksumf_%%i /ve /d "Checksum to file - %%i!scf!" /f >nul 2>&1 || ((call:err 1161) & goto:eof)
        REG ADD HKCR\*\shell\checksumf_%%i /v "Icon" /d "%_icon%" /f >nul 2>&1 || ((call:err 1360) & goto:eof)
        REG ADD HKCR\*\shell\checksumf_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i F" /f >nul 2>&1 || ((call:err 1170) & goto:eof)
    )
    if "%modl%"=="1" (
        if "!scl!"=="1" (set "scl= (&L)") else set scl=
        REG ADD HKCR\*\shell\checksuml_%%i /ve /d "Checksum lowercase - %%i!scl!" /f >nul 2>&1 || ((call:err 1201) & goto:eof)
        REG ADD HKCR\*\shell\checksuml_%%i /v "Icon" /d "%_icon%" /f >nul 2>&1 || ((call:err 1361) & goto:eof)
        REG ADD HKCR\*\shell\checksuml_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i L" /f >nul 2>&1 || ((call:err 1210) & goto:eof)
    )
    if "%modq%"=="1" (
        if "!sck!"=="1" (set "sck= (&K)") else set sck=
        REG ADD HKCR\*\shell\checksumq_%%i /ve /d "Checksum to clipboard - %%i!sck!" /f >nul 2>&1 || ((call:err 1240) & goto:eof)
        REG ADD HKCR\*\shell\checksumq_%%i /v "Icon" /d "%_icon%" /f >nul 2>&1 || ((call:err 1362) & goto:eof)
        REG ADD HKCR\*\shell\checksumq_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i Q" /f >nul 2>&1 || ((call:err 1251) & goto:eof)
    )
)
SETLOCAL DISABLEDELAYEDEXPANSION
goto afterccmn
:afterccmn
echo;
echo ^> Writting the batch file to %_target%...
(echo @echo off)>deploy.tmp || ((call:err 610) & goto:eof)
attrib +h deploy.tmp
(echo title %_title% %_version%)>>deploy.tmp
(echo rem %_title% %_version%)>>deploy.tmp
(echo rem %_crinfo%)>>deploy.tmp
(echo if "%%~1"=="" goto:eof)>>deploy.tmp
(echo if not exist "%%~1" goto:eof)>>deploy.tmp
(echo if "%%~z1"=="0" goto:eof)>>deploy.tmp
(echo if "%%3" NEQ "" ^()>>deploy.tmp
(echo     SETLOCAL ENABLEDELAYEDEXPANSION)>>deploy.tmp
(echo     set "_mode=%%3")>>deploy.tmp
(echo     set "_C=0")>>deploy.tmp
(echo     set "_F=0")>>deploy.tmp
(echo     set "_L=0")>>deploy.tmp
(echo     set "_Q=0")>>deploy.tmp
(echo     set "len=0")>>deploy.tmp
(echo     :parse)>>deploy.tmp
(echo     set "tran=!_mode:~%%len%%,1!")>>deploy.tmp
(echo     set /a "len+=1")>>deploy.tmp
(echo     if "!tran!" NEQ "" ^()>>deploy.tmp
(echo         if "!tran!"=="C" ^()>>deploy.tmp
(echo             set "_C=1")>>deploy.tmp
(echo             goto parse)>>deploy.tmp
(echo         ^))>>deploy.tmp
(echo         if "!tran!"=="F" ^()>>deploy.tmp
(echo             set "_F=1")>>deploy.tmp
(echo             goto parse)>>deploy.tmp
(echo         ^))>>deploy.tmp
(echo         if "!tran!"=="L" ^()>>deploy.tmp
(echo             set "_L=1")>>deploy.tmp
(echo             goto parse)>>deploy.tmp
(echo         ^))>>deploy.tmp
(echo         if "!tran!"=="Q" ^()>>deploy.tmp
(echo             set "_Q=1")>>deploy.tmp
(echo             goto parse)>>deploy.tmp
(echo         ^))>>deploy.tmp
(echo     ^))>>deploy.tmp
(echo     SETLOCAL DISABLEDELAYEDEXPANSION)>>deploy.tmp
(echo ^))>>deploy.tmp
(echo echo %%~1)>>deploy.tmp
(echo set mout=)>>deploy.tmp
(echo FOR /F "skip=1 delims=" %%%%i IN ^('CertUtil -hashfile %%1 %%2'^) do if not defined mout set mout=%%%%i)>>deploy.tmp
if "%lcase%"=="1" goto lcase
(echo if "%%_L%%"=="1" goto skipupper)>>deploy.tmp
(echo set moutupper=)>>deploy.tmp
(echo FOR /F "skip=2 delims=" %%%%I in ^('tree "\%%mout%%"'^) do if not defined moutupper set "moutupper=%%%%~I")>>deploy.tmp
(echo set "mout=%%moutupper:~3%%")>>deploy.tmp
(echo :skipupper)>>deploy.tmp
:lcase
(echo if "%%_F%%"=="1" ^()>>deploy.tmp
(echo     echo %%~n1%%~x1^>"%%~n1%%~x1.%%2.txt")>>deploy.tmp
(echo     echo %%2: %%mout%%^>^>"%%~n1%%~x1.%%2.txt")>>deploy.tmp
(echo     goto:eof)>>deploy.tmp
(echo ^))>>deploy.tmp
(echo set /p=%%2: ^< nul)>>deploy.tmp
(echo echo %%mout%%)>>deploy.tmp
(echo echo;)>>deploy.tmp
(echo echo ^| set /p=%%mout%%^| clip)>>deploy.tmp
(echo if "%%_Q%%"=="1" goto:eof)>>deploy.tmp
(echo echo Checksum has been copied to clipboard.)>>deploy.tmp
(echo echo;)>>deploy.tmp
(echo pause)>>deploy.tmp
del /f /q %_target% >nul 2>&1
del /ah /f /q %_target% >nul 2>&1
echo f |xcopy deploy.tmp %_target% /h /y >nul 2>&1 || ((call:err 920) & goto:eof)
attrib +r +h %_target%
call:DelTmp
goto Finished

:uninstall
call:delreg
del /f /q %_target% >nul 2>&1
del /ah /f /q %_target% >nul 2>&1
if exist %_target% (call:err 1020) & goto:eof
goto Finished_0

:Finished
echo;
echo ^> Deployment is finished.
echo;
set /p=^> <nul
if "%cfmd2%" NEQ "1" pause
goto:eof

:Finished_0
echo;
echo ^> Uninstallation has finished.
echo;
echo ^> If checksum items still exist in context menu, please run this script as adminitrator and unistall again.
echo;
set /p=^> <nul
pause
goto:eof

:err
call:deltmp
cls
echo;
echo ^> Error code: %1
echo;
echo ^> Please run this script as administrator.
echo;
set /p=^> <nul
pause
goto:eof

:DelTmp
del /f /q deploy.tmp >nul 2>&1
del /ah /f /q deploy.tmp >nul 2>&1
goto:eof

:DelReg
REG DELETE HKCR\*\shell\checksum /f >nul 2>&1
for %%i in (MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512) do (
    REG DELETE HKCR\*\shell\checksum_%%i /f >nul 2>&1
    REG DELETE HKCR\*\shell\checksuma_%%i /f >nul 2>&1
    REG DELETE HKCR\*\shell\checksumc_%%i /f >nul 2>&1
    REG DELETE HKCR\*\shell\checksumf_%%i /f >nul 2>&1
    REG DELETE HKCR\*\shell\checksuml_%%i /f >nul 2>&1
    REG DELETE HKCR\*\shell\checksumq_%%i /f >nul 2>&1
)
goto:eof
