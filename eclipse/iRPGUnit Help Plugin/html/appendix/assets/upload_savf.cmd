@echo off
rem **************************************************************
rem *  This is an MS-DOS BATCH file for uploading the
rem *  RPGUNIT save file to a System i server.
rem **************************************************************
set TEMPFILE=rpgunit.ftpcmds
set HOST=%1
set USER=%2
set PASSWORD=%3
set LIB=QGPL
set RMT_FILE=RPGUNIT
set LCL_FILE=

if "%HOST%"=="" goto help
if "%USER%"=="" goto help
if "%PASSWORD%"=="" goto help

:findFile
set count=0
for %%f in (*.SAVF) do (
   set /a count+=1
   set LCL_FILE=%%f
)
if not "%count%"=="1" (goto tooMuchFiles)



:askUser
cls
echo *************************************************************
echo   You are about to uploaded %LCL_FILE% to
echo   file %LIB%/%RMT_FILE% on host %HOST%.
echo.
echo   If the file %LIB%/%RMT_FILE% does already exist
echo   it will be deleted.
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
echo quote DLTF FILE(%LIB%/%RMT_FILE%) >> %TEMPFILE%
echo quote rcmd CRTSAVF FILE(%LIB%/%RMT_FILE%) >> %TEMPFILE%
echo binary >> %TEMPFILE%
echo put %LCL_FILE% %LIB%/%RMT_FILE% >> %TEMPFILE%

echo quit >> %TEMPFILE%
ftp -s:%TEMPFILE% %HOST%
del %TEMPFILE%

echo *************************************************************
echo   Successfully uploaded %LCL_FILE% to library %LIB% on
echo   host %HOST%.
echo   Now log on to host %HOST% and execute the
echo   following commands:
echo      1. RSTLIB SAVLIB(RPGUNIT) DEV(*SAVF)
echo            SAVF(%LIB%/%RMT_FILE%)
echo      2. ADDLIBLE RPGUNIT
echo      3. CRTBNDCL PGM(RPGUNIT/A_INSTALL)
echo            SRCFILE(RPGUNIT/RPGUNIT1) SRCMBR(*PGM)
echo      4. CALL PGM(RPGUNIT/A_INSTALL) PARM('RPGUNIT')
echo *************************************************************
goto end

:tooMuchFiles
echo.
echo. Error: Too much files with extension *.SAVF found!
for %%f in (*.SAVF) do (
   echo.        %%f
)
echo.
echo. Stopped uploading RPGUNIT to host: %HOST%.
echo.
goto end

:help
echo.
echo Uploads the RPGUNIT save file to your iSeries.
echo.
echo. upload_savf.cmd HOST USER PASSWORD
echo.
echo      HOST = FTP host you want to upload to (as400.example.com)
echo      USER = UserID to log in with
echo  PASSWORD = Password to log in with
echo.
:end
