@echo off
setlocal

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Running as non-administrator. Restarting as administrator...
    :: Relaunch the script with elevated privileges
    powershell -command "Start-Process cmd -ArgumentList '/c', '%~dpnx0' -Verb RunAs"
    exit /b
)

set root_folder=%USERPROFILE%
set starship_config_path=%root_folder%\Documents\starship\starship.toml

setx STARSHIP_CONFIG "%starship_config_path%"
setx STARSHIP_CACHE "%USERPROFILE%\AppData\Local\Temp"

exit /b