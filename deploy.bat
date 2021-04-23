@setlocal enableExtensions enableDelayedExpansion
@pushd %~dp0

@set "_title=Checksum"
@set "_version=4.6.2"
@set "_target=%USERPROFILE%\checksum.bat"
@set "_icon=%SystemRoot%\System32\SHELL32.dll,-23"
@set "_crinfo=https://github.com/lxvs/checksum"
@title %_title% %_version% Deployment
@echo %_title% %_version%
@echo %_crinfo%
@echo;
@echo ^> Release Notes won't show here since 4.4.1.
@echo ^> Please see README and CHANGELOG.
@call:Deltmp

:modeDisp
@echo;
@echo ^> Please choose algorithms ^& options
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
@echo ^> You can choose multiple items by adding the numbering. For example,
@echo;
@echo   ^| 4+16         MD5 and SHA256, UPPERCASE output only.
@echo   ^| 4+16L        MD5 and SHA256, lowercase output only.
@echo   ^| 4+16+256     MD5 and SHA256, UPPERCASE and lowercase output.
@echo;
@echo ^> 16+512+1024 ^(1552^) is recommended.
@goto modeInput

:unexp
@echo;
@echo ^> Unexpected value input.

:modeInput
@set /p=$ <nul
@set mod=
@set /p mod=
@if "%mod%"=="" goto modeinput
@if "%mod%"=="0" goto uninstall
@if /i "%mod%"=="q" exit /b 0
@if /i "%mod%"=="quit" exit /b 0
@if /i "%mod%"=="exit" exit /b 0
@set cfmd=
@set cfmd2=
@set lcase=
@if /i "%mod:~-1%"=="Y" (
    set "mod=%mod:~0,-1%"
    @set cfmd=1
)
@if "%cfmd%"=="1" if /i "%mod:~-1%"=="Y" (
    set "mod=%mod:~0,-1%"
    @set cfmd2=1
)
@if /i "%mod:~-1%"=="L" (
    set "mod=%mod:~0,-1%"
    @set lcase=1
)
@set /a mod=%mod% 1>nul 2>&1 || goto unexp
@if "%mod%"=="0" goto unexp
@set /a "alg0=mod/1%%2"
@set /a "alg1=mod/2%%2"
@set /a "alg2=mod/4%%2"
@set /a "alg3=mod/8%%2"
@set /a "alg4=mod/16%%2"
@set /a "alg5=mod/32%%2"
@set /a "alg6=mod/64%%2"
@set /a "ccmn=mod/128%%2"
@set /a "modl=mod/256%%2"
@set /a "modq=mod/512%%2"
@set /a "modf=mod/1024%%2"
@set /a "dcol=mod/4096%%2"

@set /a "algs=alg0+alg1+alg2+alg3+alg4+alg5+alg6"
@if %algs% LEQ 0 goto unexp
@set /p=^> You choosed: <nul

@set alg=
@if %alg0% EQU 1 set "alg=%alg% MD2"
@if %alg1% EQU 1 set "alg=%alg% MD4"
@if %alg2% EQU 1 set "alg=%alg% MD5"
@if %alg3% EQU 1 set "alg=%alg% SHA1"
@if %alg4% EQU 1 set "alg=%alg% SHA256"
@if %alg5% EQU 1 set "alg=%alg% SHA384"
@if %alg6% EQU 1 set "alg=%alg% SHA512"

@set /p=%alg%<nul
@if %ccmn% EQU 1 set /p=, cascaded menu<nul
@if %modl% EQU 1 set /p=, lowercase mode<nul
@if %modq% EQU 1 set /p=, quiet mode<nul
@if %modf% EQU 1 set /p=, output-to-file mode<nul
@if %dcol% EQU 1 set /p=, colorful output disabled<nul
@set /p=, right? ^(Y^/N^): <nul
@if "%cfmd%" == "1" (
    @set "confirm=Y"
    @set /p=Y<nul
    @echo;
) else (
    @set confirm=
    @set /p confirm=
)
@if /i "%confirm%" NEQ "Y" goto modeInput
@if %dcol% EQU 1 (
    @set algPre=
    @set fnmPre=
    @set outPre=
    @set errPre=
    @set sucPre=
    @set suf=
) else (
    @set "algPre=[92m"
    @set "fnmPre=[92m"
    @set "outPre=[93m"
    @set "errPre=[93;101m"
    @set "sucPre=[92m"
    @set "suf=[0m"
)
@echo ^> Adding checksum to context menu...
@call:delReg
@if %ccmn% EQU 1 (@goto ccmn1) else @goto ccmn0

:ccmn1
@REG ADD HKCR\*\shell\checksum /v "MUIVerb" /d "Checksum (&Q)" /f 1>nul 2>&1 || (
    @call:Err 1250
    @exit /b
)
@REG ADD HKCR\*\shell\checksum /v "Icon" /d "%_icon%" /f 1>nul 2>&1 || (
    @call:Err 1252
    @exit /b
)
@REG ADD HKCR\*\shell\checksum /v "SubCommands"  /f 1>nul 2>&1 || (
    @call:Err 1260
    @exit /b
)
@REG ADD HKCR\*\shell\checksum\shell /f 1>nul 2>&1 || (
    @call:Err 1270
    @exit /b
)
@set /a "index=0"
@set /a "scnum=0"
@set "sckey="
@for %%i in (%alg%) do @(
    @set /a "index+=1"
    @set /a "scnum=index"
    @if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
    @if !scnum! EQU 10 set "sckey= (&0)"
    @REG ADD HKCR\*\shell\checksum\shell\a_%%i /ve /d "%%i!sckey!" /f 1>nul 2>&1 || (
        @call:Err 1290
        @exit /b
    )
    @REG ADD HKCR\*\shell\checksum\shell\a_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i" /f 1>nul 2>&1 || (
        @call:Err 1300
        @exit /b
    )
    @if %modf% EQU 1 (
        @set /a "scnum+=algs"
        @if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        @if !scnum! EQU 10 set "sckey= (&0)"
        @REG ADD HKCR\*\shell\checksum\shell\f_%%i /ve /d "To file - %%i!sckey!" /f 1>nul 2>&1 || (
            @call:Err 1110
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksum\shell\f_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i F" /f 1>nul 2>&1 || (
            @call:Err 1120
            @exit /b
        )
    )
    @if %modl% EQU 1 (
        @set /a "scnum+=algs"
        @if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        @if !scnum! EQU 10 set "sckey= (&0)"
        @REG ADD HKCR\*\shell\checksum\shell\l_%%i /ve /d "Lowercase - %%i!sckey!" /f 1>nul 2>&1 || (
            @call:Err 1150
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksum\shell\l_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i L" /f 1>nul 2>&1 || (
            @call:Err 1160
            @exit /b
        )
    )
    @if %modq% EQU 1 (
        @set /a "scnum+=algs"
        @if !scnum! GEQ 10 (set "sckey=") else set "sckey= (&!scnum!)"
        @if !scnum! EQU 10 set "sckey= (&0)"
        @REG ADD HKCR\*\shell\checksum\shell\q_%%i /ve /d "To clipboard - %%i!sckey!" /f 1>nul 2>&1 || (
            @call:Err 1190
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksum\shell\q_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i Q" /f 1>nul 2>&1 || (
            @call:Err 1200
            @exit /b
        )
    )
)
@goto afterccmn

:ccmn0
@set "scq=1"
@set "scf=1"
@set "scl=1"
@set "sck=1"
@for %%i in (%alg%) do @(
    @if "!scq!"=="1" (set "scq= (&Q)") else set scq=
    @REG ADD HKCR\*\shell\checksuma_%%i /ve /d "Checksum - %%i!scq!" /f 1>nul 2>&1 || (
        @call:Err 560
        @exit /b
    )
    @REG ADD HKCR\*\shell\checksuma_%%i /v "Icon" /d "%_icon%" /f 1>nul 2>&1 || (
        @call:Err 1330
        @exit /b
    )
    @REG ADD HKCR\*\shell\checksuma_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i" /f 1>nul 2>&1 || (
        @call:Err 570
        @exit /b
    )
    @if %modf% EQU 1 (
        @if "!scf!"=="1" (set "scf= (&F)") else set scf=
        @REG ADD HKCR\*\shell\checksumf_%%i /ve /d "Checksum to file - %%i!scf!" /f 1>nul 2>&1 || (
            @call:Err 1161
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksumf_%%i /v "Icon" /d "%_icon%" /f 1>nul 2>&1 || (
            @call:Err 1360
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksumf_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i F" /f 1>nul 2>&1 || (
            @call:Err 1170
            @exit /b
        )
    )
    @if %modl% EQU 1 (
        @if "!scl!"=="1" (set "scl= (&L)") else set scl=
        @REG ADD HKCR\*\shell\checksuml_%%i /ve /d "Checksum lowercase - %%i!scl!" /f 1>nul 2>&1 || (
            @call:Err 1201
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksuml_%%i /v "Icon" /d "%_icon%" /f 1>nul 2>&1 || (
            @call:Err 1361
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksuml_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i L" /f 1>nul 2>&1 || (
            @call:Err 1210
            @exit /b
        )
    )
    @if %modq% EQU 1 (
        @if "!sck!"=="1" (set "sck= (&K)") else set sck=
        @REG ADD HKCR\*\shell\checksumq_%%i /ve /d "Checksum to clipboard - %%i!sck!" /f 1>nul 2>&1 || (
            @call:Err 1240
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksumq_%%i /v "Icon" /d "%_icon%" /f 1>nul 2>&1 || (
            @call:Err 1362
            @exit /b
        )
        @REG ADD HKCR\*\shell\checksumq_%%i\command /ve /d "\"%_target%\" \"%%1\" %%i Q" /f 1>nul 2>&1 || (
            @call:Err 1251
            @exit /b
        )
    )
)
@goto afterccmn

:afterccmn
@echo ^> Writting the batch file to %_target%...
@setlocal disableDelayedExpansion
@(
echo @setlocal enableExtensions enableDelayedExpansion
echo @rem %_crinfo%
echo @title %_title% %_version%
echo @if "%%~1" == "" @exit /b 1
echo @if not exist "%%~1" ^(
echo     @call:ChksmErr 1950 "file %%~1 does not exist."
echo     @exit /b
echo ^)
echo @if "%%~z1" == "0" ^(
echo     @call:ChksmErr 1990 "file %%~1 is empty."
echo     @exit /b
echo ^)
echo @if not "%%3" == "" ^(
echo     @set "_mode=%%3"
echo     @set "_F=0"
echo     @set "_L=0"
echo     @set "_Q=0"
echo     @set "len=0"
echo     @goto parse
echo ^) else @goto postparse
echo :parse
echo @set "tran=!_mode:~%%len%%,1!"
echo @set /a "len+=1"
echo @if "!tran!" NEQ "" ^(
echo     @if "!tran!"=="F" ^(
echo         @set "_F=1"
echo         @goto parse
echo     ^)
echo     @if "!tran!"=="L" ^(
echo         @set "_L=1"
echo         @goto parse
echo     ^)
echo     @if "!tran!"=="Q" ^(
echo         @set "_Q=1"
echo         @goto parse
echo     ^)
echo ^)
echo :postparse
echo @set "fpath=%%~dp1"
echo @set "fname=%%~nx1"
echo @if not "%%_Q%%" == "1" @if not "%%_F%%" == "1" @echo %%fpath:^^=^^^^%%%fnmpre%%%fname:^^=^^^^%%%suf%
echo @set mout=
echo @FOR /F "skip=1 delims=" %%%%i IN ^('CertUtil -hashfile %%1 %%2'^) do @if not defined mout set mout=%%%%i
echo @if /i "%%mout:~0,8%%"=="certutil" @goto cuerr
if not "%lcase%" == "1" (
    echo @if "%%_L%%"=="1" goto skipupper
    echo @set moutupper=
    echo @FOR /F "skip=2 delims=" %%%%I in ^('tree "\%%mout%%"'^) do @if not defined moutupper set "moutupper=%%%%~I"
    echo @set "mout=%%moutupper:~3%%"
    echo :skipupper
)
echo @if "%%_F%%" == "1" goto fileoutput
echo @echo ^| set /p=%%mout%%^| clip
echo @if "%%_Q%%" == "1" exit /b 0
echo @set /p=%algpre%%%2%suf%: ^<nul
echo @echo %outpre%%%mout%%%suf%
echo @echo;
echo @echo Checksum has been copied to clipboard.
echo @echo;
echo @pause
echo @exit /b 0
echo :fileoutput
echo @set "fnamef=%%~nx1"
echo @set "fnamefR=%%fnamef:^=^^%%"
echo @echo %%fnamefR%%^>"%%fnamef%%_%%2.txt"
echo @echo %%2: %%mout%%^>^>"%%fnamef%%_%%2.txt"
echo @exit /b 0
echo :cuerr
echo @^(certutil -hashfile %%1 %%2^) 1^>nul 2^>^&1
echo @echo %errpre%%%mout:~10%%%suf%
echo @echo;
echo @pause
echo @exit /b
echo :ChksmErr
echo @echo %errpre%Error^(%%1^): %%~2%suf%
echo @echo;
echo @pause
echo @exit /b %%1
)>deploy.tmp || (
    @call:Err 610
    @exit /b
)
@attrib +h deploy.tmp
@setlocal enableDelayedExpansion
@del /f /q %_target% 1>nul 2>&1
@del /ah /f /q %_target% 1>nul 2>&1
@echo f | xcopy deploy.tmp %_target% /h /y 1>nul 2>&1 || (
    @call:Err 920
    @exit /b
)
@attrib +r +h %_target%
@call:DelTmp
@echo %sucPre%^> Deployment is finished.%suf%
@if "%cfmd2%" NEQ "1" pause
@exit /b 0

:uninstall
@call:Delreg
@del /f /q %_target% 1>nul 2>&1
@del /ah /f /q %_target% 1>nul 2>&1
@if exist %_target% (
    @call:Err 1020
    @exit /b
)
@echo ^> Uninstallation has finished.
@echo ^> If checksum items still exist in context menu, please run this script as adminitrator and unistall again.
@echo;
@pause
@exit /b 0

:Err
@call:Deltmp
@echo;
@echo ^> %errpre%ERROR%suf%
@echo ^> Error code: %1
@echo ^> Please run this script as administrator.
@echo;
@pause
@exit /b %1

:DelTmp
@del /f /q deploy.tmp 1>nul 2>&1
@del /ah /f /q deploy.tmp 1>nul 2>&1
@exit /b 0

:DelReg
@REG DELETE HKCR\*\shell\checksum /f 1>nul 2>&1
@for %%i in (MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512) do @(
    REG DELETE HKCR\*\shell\checksum_%%i /f 1>nul 2>&1
    REG DELETE HKCR\*\shell\checksuma_%%i /f 1>nul 2>&1
    REG DELETE HKCR\*\shell\checksumc_%%i /f 1>nul 2>&1
    REG DELETE HKCR\*\shell\checksumf_%%i /f 1>nul 2>&1
    REG DELETE HKCR\*\shell\checksuml_%%i /f 1>nul 2>&1
    REG DELETE HKCR\*\shell\checksumq_%%i /f 1>nul 2>&1
)
@exit /b 0
