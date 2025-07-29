Write-Host "`nChecking for updates with winget..."
winget update

Write-Host "`nUpgrading all packages with winget..."
winget upgrade --all --accept-source-agreements --accept-package-agreements

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$batPath = Join-Path $scriptDir 'install_spotify.bat'

if (Test-Path $batPath) {
    Write-Host "`nRunning install_spotify.bat..."
    Start-Process -FilePath $batPath -Wait
} else {
    Write-Warning "install_spotify.bat not found at: $batPath"
}
