Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Set-Location -Path $PSScriptRoot

#Requires -RunAsAdministrator

## Debloat
echo "Run Sophia Script, this will take a while..."
.\Windows\Sophia.ps1

## Check Health
echo "Checking Health..."
Start-Process -FilePath ".\Windows\check_health.bat" -Wait

## Installing programs
echo "Installing Programs..."
.\Windows\instalation_programs.ps1

## Customization 
echo "Customization..."
.\Windows\customization.ps1

## Enviromental Varibles
echo "Set Enviromental Variables..."
Start-Process -FilePath ".\Windows\enviroment_variables.bat" -Wait

## Tasks
echo "Remove tasks..."
.\Windows\remove_tasks.ps1
echo "Installl tasks..."
.\Windows\reinstall_tasks.ps1


## Update
echo "Update packages..."
.\Windows\auto_updater.ps1

Exit 0
