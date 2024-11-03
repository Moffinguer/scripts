Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Set-Location -Path $PSScriptRoot

#Requires -RunAsAdministrator

## Debloat
.\Windows\Sophia.ps1

## Uninstall Programs
# After doing a reboot I would like to check which packages can be removed

## Installing programs
#.\Windows\Instalation_Programs.ps1

## Customization 
#.\Windows\Customization.ps1

## Enviromental Varibles
#Start-Process -FilePath ".\Windows\enviroment_variables.bat" -Wait

# To allow the execution of custom scripts after everything has ended
#Set-ExecutionPolicy  RemoteSigned -Scope CurrentUser

Exit 0
