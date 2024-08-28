@echo off

set param=-confirm_uninstall_ms_spoti -confirm_spoti_recomended_uninstall -new_theme -topsearchbar -rightsidebar_off -lyrics_stat zing -adsections_off -funnyprogressBar -plus -language es -podcasts_on -block_update_on -start_spoti -no_shortcut
set url=https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1
set url2=https://spotx-official.github.io/run.ps1
set tls=[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12;

%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe ^
-Command %tls% $p='%param%'; """ & { $(try { iwr -useb %url% } catch { $p+= ' -m'; iwr -useb %url2% })} $p """" | iex

pause
exit /b