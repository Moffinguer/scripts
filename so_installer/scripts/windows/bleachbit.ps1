Add-Type -AssemblyName PresentationFramework

$bleachbitPath = "$env:LOCALAPPDATA\BleachBit\bleachbit_console.exe"

if (-Not (Test-Path $bleachbitPath)) {
    [System.Windows.MessageBox]::Show(
        "BleachBit no está instalado. Por favor, instálalo antes de ejecutar este script.",
        "BleachBit no encontrado",
        "OK",
        "Warning"
    )
    exit 0
}

$cleaners = @(
    "brave.cache", "brave.dom", "brave.form_history", "brave.history", "brave.passwords",
    "brave.search_engines", "brave.session", "brave.sync", "brave.vacuum",
    "deepscan.backup", "deepscan.ds_store", "deepscan.thumbs_db", "deepscan.tmp",
    "deepscan.vim_swap_root", "deepscan.vim_swap_user",
    "discord.cache", "discord.cookies", "discord.history", "discord.vacuum",
    "firefox.backup", "firefox.cache", "firefox.cookies", "firefox.crash_reports",
    "firefox.dom", "firefox.forms", "firefox.passwords", "firefox.session_restore",
    "firefox.site_preferences", "firefox.url_history", "firefox.vacuum",
    "internet_explorer.cache", "internet_explorer.cookies", "internet_explorer.downloads",
    "internet_explorer.forms", "internet_explorer.history", "internet_explorer.logs",
    "microsoft_edge.cache", "microsoft_edge.cookies", "microsoft_edge.dom",
    "microsoft_edge.form_history", "microsoft_edge.history", "microsoft_edge.passwords",
    "microsoft_edge.search_engines", "microsoft_edge.session", "microsoft_edge.site_preferences",
    "microsoft_edge.sync", "microsoft_edge.vacuum",
    "microsoft_office.debug_logs", "microsoft_office.mru",
    "system.clipboard", "system.custom", "system.free_disk_space", "system.logs",
    "system.memory_dump", "system.muicache", "system.prefetch", "system.recycle_bin",
    "system.tmp", "system.updates",
    "windows_defender.backup", "windows_defender.history", "windows_defender.logs",
    "windows_defender.quarantine", "windows_defender.temp",
    "windows_explorer.mru", "windows_explorer.run", "windows_explorer.search_history"
)

$progress = New-Object System.Windows.Window
$progress.Title = "BleachBit - Limpiando..."
$progress.Width = 300
$progress.Height = 100
$progress.WindowStartupLocation = "CenterScreen"

$stackPanel = New-Object System.Windows.Controls.StackPanel
$label = New-Object System.Windows.Controls.Label
$label.Content = "Ejecutando limpieza, espera un momento..."
$stackPanel.Children.Add($label)

$progress.Content = $stackPanel
$progress.Show()

foreach ($cleaner in $cleaners) {
    & $bleachbitPath --clean $cleaner 2>$null
}

Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    & $bleachbitPath --wipe-free-space $_.Root 2>$null
}

$progress.Close()

[System.Windows.MessageBox]::Show(
    "Limpieza completada correctamente.",
    "Finalizado",
    "OK",
    "Information"
)

ipconfig /flushdns | Out-Null

nbtstat -R | Out-Null
nbtstat -RR | Out-Null

Try {
    Clear-DnsClientCache | Out-Null
} Catch {
    # Ignore errors in case the cmdlet isn't available
}


$sdeleteInstalled = winget list --id Microsoft.Sysinternals.SDelete -e -ErrorAction SilentlyContinue

if (-not $sdeleteInstalled) {
    Write-Output "sdelete no encontrado. Intentando instalarlo con winget..."

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Microsoft.Sysinternals.SDelete -e -i --silent --accept-source-agreements --accept-package-agreements

        $sdeleteInstalled = winget list --id Microsoft.Sysinternals.SDelete -e -ErrorAction SilentlyContinue
        if (-not $sdeleteInstalled) {
            Write-Output "Error: sdelete no se pudo instalar correctamente."
        } else {
            Write-Output "sdelete instalado correctamente."
        }
    } else {
        Write-Output "Winget no está disponible. No se puede instalar sdelete automáticamente."
    }
}

Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:TEMP\*"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:WINDIR\Temp\*"

Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:APPDATA\Microsoft\Windows\Recent\*"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\*"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations\*"

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Clear-Clipboard

wevtutil el | ForEach-Object { wevtutil cl $_ } 2>$null

ie4uinit.exe -ClearIconCache 2>$null

Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:SystemRoot\Prefetch\*"

powercfg -h off

Dism.exe /Online /Cleanup-Image /StartComponentCleanup /Quiet /NoRestart

Get-PhysicalDisk | Where-Object MediaType -eq 'HDD' | ForEach-Object {
    Get-Volume -FileSystemLabel $_.FriendlyName | ForEach-Object {
        defrag $_.DriveLetter`: -f
    }
}

Get-ScheduledTask | Where-Object { $_.State -eq 'Disabled' } | Unregister-ScheduledTask -Confirm:$false

Write-Output "Programas en el inicio:"
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location

sdelete.exe -z C:

exit 0
