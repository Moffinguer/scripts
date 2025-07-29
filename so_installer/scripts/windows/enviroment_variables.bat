@echo off
setlocal

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Running as non-administrator. Restarting as administrator...
    :: Relaunch the script with elevated privileges
    powershell -command "Start-Process cmd -ArgumentList '/c', '%~dpnx0' -Verb RunAs"
    exit /b
)

exit /b