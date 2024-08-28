Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

.\Windows\Sophia.ps1

Start-Process -FilePath "..\..\utils\Install_Spotify.bat" -Wait
Exit 0
