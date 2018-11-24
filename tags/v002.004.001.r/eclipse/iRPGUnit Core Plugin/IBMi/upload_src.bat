@echo off
rem **************************************************************
rem *  This is an MS-DOS BATCH file for uploading the
rem *  RPGUnit save file to an i5 server.
rem **************************************************************
set TEMPFILE=rpgunit.ftpcmds
set HOST=%1
set USER=%2
set PASSWORD=%3
set LIB=%4

set SOURCE_ROOT=.\source

if "%HOST%"=="" goto help
if "%USER%"=="" goto help
if "%PASSWORD%"=="" goto help
if "%LIB%"=="" goto help

:askUser
cls
echo *************************************************************
echo   You are about to uploaded the RPGUnit source member
echo   to library %LIB% on host %HOST%.
echo *************************************************************
set choice=
set /p choice=Do you want to continue? (y/n)
if /i "%choice%"=="y" goto continue
if /i "%choice%"=="n" goto end
goto askUser

:continue
echo %USER%> %TEMPFILE%
echo %PASSWORD%>> %TEMPFILE%
echo quote site namefmt 0 >> %TEMPFILE%
echo quote type c 819 >> %TEMPFILE%

echo quote rcmd CRTLIB LIB(RPGUNIT) TYPE(*TEST) TEXT('RPGUnit RDP Plugin') >> %TEMPFILE%
echo cd RPGUNIT >> %TEMPFILE%

set FILE=RPGUNITC1
echo quote crts FILE(%LIB%/%FILE%) TEXT('Tool: RPGUnit - Commands.') RCDLEN(112) >> %TEMPFILE%
echo mput %SOURCE_ROOT%\%FILE%.file\%FILE%.*  >> %TEMPFILE%

set FILE=RPGUNITF1
echo quote crts FILE(%LIB%/%FILE%) TEXT('Tool: RPGUnit - Test Fixtures.') RCDLEN(112) >> %TEMPFILE%
echo mput %SOURCE_ROOT%\%FILE%.file\%FILE%.*  >> %TEMPFILE%

set FILE=RPGUNITT1
echo quote crts FILE(%LIB%/%FILE%) TEXT('Tool: RPGUnit - Self-Test.') RCDLEN(112) >> %TEMPFILE%
echo mput %SOURCE_ROOT%\%FILE%.file\%FILE%.* >> %TEMPFILE%

set FILE=RPGUNITY1
echo quote crts FILE(%LIB%/%FILE%) TEXT('Tool: RPGUnit - Prototypes.') RCDLEN(112) >> %TEMPFILE%
echo mput %SOURCE_ROOT%\%FILE%.file\%FILE%.* >> %TEMPFILE%

set FILE=RPGUNIT1
echo quote crts FILE(%LIB%/%FILE%) TEXT('Tool: RPGUnit - Framework.') RCDLEN(112) >> %TEMPFILE%
echo mput %SOURCE_ROOT%\%FILE%.file\%FILE%.* >> %TEMPFILE%

echo quote rcmd ADDLIBLE %LIB% >> %TEMPFILE%
echo quote rcmd CRTBNDCL PGM(QTEMP/MKMETADATA) SRCFILE(%LIB%/RPGUNIT1) SRCMBR(*PGM) OUTPUT(*NONE) >> %TEMPFILE%
echo quote rcmd CALL PGM(QTEMP/MKMETADATA) >> %TEMPFILE%

echo quit >> %TEMPFILE%

:ftp
ftp -i -s:%TEMPFILE% %HOST%
del %TEMPFILE%

echo *************************************************************
echo   Successfully uploaded all source members of RPGUnit
echo   to file %LIB%/%FILE% on host %HOST%.
echo   Now log on to host %HOST% and execute the 
echo   following commands:
echo      1. ADDLIBLE LIB(%LIB%)
echo      2. CRTBNDCL PGM(QTEMP/A_INSTALL) 
echo            SRCFILE(%LIB%/RPGUNIT1) SRCMBR(*PGM)
echo      3. CALL PGM(QTEMP/A_INSTALL) PARM(%LIB%)
echo *************************************************************
goto end

:help
echo.
echo Uploads the RPGUnit source members to your i5.
echo.
echo. upload_src.bat HOST USER PASSWORD
echo.
echo      HOST = FTP host you want to upload to (as400.example.com)
echo      USER = UserID to log in with
echo  PASSWORD = Password to log in with
echo       LIB = Target library
echo.
:end 