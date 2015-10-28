@echo off

echo Select the App Descriptor to use:
echo 1. Pomodairo
echo 2. DatabaseViewer
echo 3. StatisticsViewer
echo 4. TaskListViewer
echo.
set /p option=
if %option%==4 (
  set APP_DESCRIPTOR=TaskListViewer-app.xml
)
if %option%==3 (
  set APP_DESCRIPTOR=StatisticsViewer-app.xml
)
if %option%==2 (
  set APP_DESCRIPTOR=DatabaseViewer-app.xml
)
if %option%==1 (
  set APP_DESCRIPTOR=Pomodairo-app.xml
)

:: Set working dir
cd %~dp0 & cd ..

set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApp.bat %APP_DESCRIPTOR%

echo.
echo Starting AIR Debug Launcher...
echo.

adl "%APP_XML%" "%APP_DIR%"
if errorlevel 1 goto error
goto end

:error
pause

:end
