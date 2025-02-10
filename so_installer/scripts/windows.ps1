Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Set-Location -Path $PSScriptRoot

#Requires -RunAsAdministrator

## Debloat
echo "Run Sophia Script, this will take a while..."
.\Windows\Sophia.ps1

## Check Health
echo "Checking Health..."
.\Windows\check_health.bat

## Installing programs
echo "Installing Programs..."
.\Windows\instalation_programs.ps1

## Customization 
echo "Customization..."
.\Windows\customization.ps1

## Enviromental Varibles
echo "Set Enviromental Variables..."
Start-Process -FilePath ".\Windows\enviroment_variables.bat" -Wait

Exit 0
