@echo off
setlocal

set param1=-confirm_uninstall_ms_spoti -confirm_spoti_recomended_uninstall -new_theme -topsearchbar -rightsidebar_off
set param2=-rightsidebarcolor -lyrics_stat zing -adsections_off -funnyprogressBar -plus
set param3=-language es -podcasts_on -block_update_on -no_shortcut

set param=%param1% %param2% %param3%

set url=https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1
set url2=https://spotx-official.github.io/run.ps1
set tls=[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12;

%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe ^
-Command "%tls%; $p='%param%'; ^" ^
"$(try { iwr -useb %url% } catch { $p+= ' -m'; iwr -useb %url2% }) $p" ^
| iex

for /f "tokens=*" %%i in ('winget list --name spotify 2^>nul') do (
    echo %%i | find /i "Spotify" >nul
    if not errorlevel 1 (
        echo Spotify found. Disabling automatic startup...
        
        reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Spotify >nul 2>&1
        if %errorlevel% == 0 (
            reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Spotify /f
            echo Spotify automatic startup disabled.
        ) else (
            echo Spotify was not configured for automatic startup.
        )
    ) else (
        echo Spotify not found.
    )
)

exit /b
