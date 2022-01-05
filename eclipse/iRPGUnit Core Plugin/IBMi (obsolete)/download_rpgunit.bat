@echo off
rem **************************************************************
rem *  This is an MS-DOS BATCH file for downloading the          *
rem *  RPGUnit source members.      RDi 9.5.1.3+                 *
rem **************************************************************
set VERSION=v1.7.3
set UTILITIES_DIR=DOS Utilities
set DATE_ISO=%date:~6,4%%date:~3,2%%date:~0,2%
set TIME_ISO=%time:~0,2%%time:~3,2%
if "%time:~0,1%"==" " set TIME_ISO=0%TIME_ISO:~1,3%
set TIMESTAMP=%DATE_ISO%_%TIME_ISO%
set ZIP_FILE=RPGUNIT_%VERSION%_%TIMESTAMP%.zip
set ZIP_FILE_FOLDER=..\..\de.tools400.rpgunit.core.updatesite\downloads
set ZIP_FILE_PATH=%ZIP_FILE_FOLDER%\%ZIP_FILE%
set UPDATE_SITE_PATH=..\..\de.tools400.rpgunit.core.updatesite
set UPDATE_SITE_DOWNLOADS=%UPDATE_SITE_PATH%\downloads
set UPDATE_SITE_FEATURES=%UPDATE_SITE_PATH%\features
set UPDATE_SITE_PLUGINS=%UPDATE_SITE_PATH%\plugins
set UPDATE_SITE_ARTIFACTS=%UPDATE_SITE_PATH%\artifacts.jar
set UPDATE_SITE_CONTENT=%UPDATE_SITE_PATH%\content.jar
set UPDATE_SITE_SITE=%UPDATE_SITE_PATH%\site.xml

set UPDATE_SITE_TEMPLATES=%UPDATE_SITE_PATH%\build\templates
set UPDATE_SITE_SAMPLE_LINK_FILE=%UPDATE_SITE_TEMPLATES%\de.tools400.rpgunit.core.link

set VERSION_PROPERTIES=version.properties
set VERSION_PROPERTIES_FOLDER=..\..\de.tools400.rpgunit.core.updatesite\build\

set TEMPFILE=rpgunit.ftpcmds
set HOST=ghentw.gfd.de
set USER=RADDATZ
set PASS=%1
set LIB=RPGUNIT

set INSTALL_SAVF_LIB=RPGUNIT
set INSTALL_SAVF_NAME=%INSTALL_SAVF_LIB%
set INSTALL_SAVF_LOCAL=%INSTALL_SAVF_NAME%_%VERSION%_%TIMESTAMP%.SAVF

if "%PASS%"=="" goto usage

if not exist source (
   md source
)

if not exist source\RPGUNIT1.FILE (
   md source\RPGUNIT1.FILE
)

if not exist source\RPGUNITC1.FILE (
   md source\RPGUNITC1.FILE
)

if not exist source\RPGUNITF1.FILE (
   md source\RPGUNITF1.FILE
)

if not exist source\RPGUNITT1.FILE (
   md source\RPGUNITT1.FILE
)

if not exist source\RPGUNITY1.FILE (
   md source\RPGUNITY1.FILE
)

del *.SAVF
del source /S /Q
del %VERSION_PROPERTIES%

del %VERSION_PROPERTIES_FOLDER%\%VERSION_PROPERTIES%
del %UPDATE_SITE_DOWNLOADS%\*.* /Q

echo %USER%> %TEMPFILE%
echo %PASS%>> %TEMPFILE%
echo quote site namefmt 0 >> %TEMPFILE%
echo cd %LIB%>> %TEMPFILE%
echo quote type c 819>> %TEMPFILE%

echo lcd source         >> %TEMPFILE%

rem  RPGUNIT1
echo lcd RPGUNIT1.FILE  >> %TEMPFILE%
echo mget RPGUNIT1.*    >> %TEMPFILE%
echo lcd ..             >> %TEMPFILE%

rem  RPGUNITC1
echo lcd RPGUNITC1.FILE >> %TEMPFILE%
echo mget RPGUNITC1.*   >> %TEMPFILE%
echo lcd ..             >> %TEMPFILE%

rem  RPGUNITF1
echo lcd RPGUNITF1.FILE >> %TEMPFILE%
echo mget RPGUNITF1.*   >> %TEMPFILE%
echo lcd ..             >> %TEMPFILE%

rem  RPGUNITT1
echo lcd RPGUNITT1.FILE >> %TEMPFILE%
echo mget RPGUNITT1.*   >> %TEMPFILE%
echo lcd ..             >> %TEMPFILE%

rem RPGUNITY1
echo lcd RPGUNITY1.FILE >> %TEMPFILE%
echo mget RPGUNITY1.*   >> %TEMPFILE%
echo lcd ..             >> %TEMPFILE%

echo lcd ..             >> %TEMPFILE%

rem Save File
echo binary >> %TEMPFILE%
echo get %INSTALL_SAVF_LIB%/%INSTALL_SAVF_NAME%  %INSTALL_SAVF_LOCAL% >> %TEMPFILE%

echo quit >> %TEMPFILE%
pause

:ftp
cls
ftp -i -s:%TEMPFILE% %HOST%
del %TEMPFILE%

:version
echo version.file=%ZIP_FILE%> %VERSION_PROPERTIES%
echo version.timestamp=%TIMESTAMP%>> %VERSION_PROPERTIES%
echo version.number=%VERSION%>> %VERSION_PROPERTIES%
xcopy "%VERSION_PROPERTIES%"  "%VERSION_PROPERTIES_FOLDER%" /Y

:index

:assets

:update_site
if not exist \local_updatesite (
   md local_updatesite
)

del local_updatesite /S /Q

xcopy "%UPDATE_SITE_FEATURES%"  ".\local_updatesite\features\"  /S
xcopy "%UPDATE_SITE_PLUGINS%"   ".\local_updatesite\plugins\"   /S
xcopy "%UPDATE_SITE_ARTIFACTS%" ".\local_updatesite\" /S
xcopy "%UPDATE_SITE_CONTENT%"   ".\local_updatesite\" /S
xcopy "%UPDATE_SITE_SITE%"      ".\local_updatesite\" /S

:zip
del %ZIP_FILE_FOLDER%\*.zip
"%UTILITIES_DIR%"\7z a -mx=8 "%ZIP_FILE_PATH%" "source\*" "local_updatesite\*" "%UPDATE_SITE_SAMPLE_LINK_FILE%" "upload_src.bat" "upload_savf.bat" "RPGUNIT_%VERSION%_*.SAVF"

:cleanup
del "RPGUNIT_%VERSION%_*.SAVF"

del local_updatesite /S /Q
rd local_updatesite\features
rd local_updatesite\plugins
rd local_updatesite

del source /S /Q
rd source\RPGUNIT1.FILE\
rd source\RPGUNITC1.FILE\
rd source\RPGUNITF1.FILE\
rd source\RPGUNITT1.FILE\
rd source\RPGUNITY1.FILE\
rd source

goto end

:usage
echo.
echo USAGE: download PASSWORD
echo.
echo  PASSWORD = Password to log in with
echo.
:end
