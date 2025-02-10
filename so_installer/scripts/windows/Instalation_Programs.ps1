# ===============================
# Función: Install-PackageAndVerify
# ===============================
# Instala un paquete y verifica si se ha instalado correctamente.
function Install-PackageAndVerify {
    param (
        [string]$PackageName,
        [string]$Extras = "-i"
    )

    $installedPackage = winget list --id $PackageName
    if ($installedPackage) {
        Write-Host "El paquete $PackageName se ha instalado correctamente."
    } else {
        Write-Host "Intentando instalar $PackageName..."

        winget install --id $PackageName $Extras

        $installedPackage = winget list --id $PackageName

        if ($installedPackage) {
            Write-Host "El paquete $PackageName se ha instalado correctamente."
        } else {
            Write-Host "El paquete $PackageName falló al instalarse."
        }
    }
}

# ============================
# Función: Package-Installer
# ============================
# Instala todos los paquetes necesarios utilizando Winget.
function Package-Installer {
    $jobs = @()

    # Instalar los paquetes en segundo plano
    $packages = @(
        "Neovim.Neovim.Nightly",
        "Brave.Brave",
        "Mozilla.Firefox",
        "Microsoft.VisualStudioCode",
        "VideoLAN.VLC",
        "mcmilk.7zip-zstd",
        "c0re100.qBittorrent-Enhanced-Edition",
        "Valve.Steam",
        "Git.Git",
        "nomacs.nomacs",
        "JackieLiu.NotepadsApp",
        "Microsoft.PowerShell",
        "Obsidian.Obsidian",
        "PeterPawlowski.foobar2000",
        "Microsoft.PowerToys",
        "Starship.Starship",
        "Flameshot.Flameshot",
        "voidtools.Everything"
    )

    foreach ($package in $packages) {
        $jobs += Start-Job -ScriptBlock {
            Install-PackageAndVerify -PackageName $using:package
        }
    }

    $jobs | ForEach-Object { 
        $job = $_
        Wait-Job $job
        Remove-Job $job
    }

    Write-Host "Todas las instalaciones se han completado."
}

# ============================
# Función: External-Installers
# ============================
# Instala software externo (como Spotify y Office).
function External-Installers {
    $spotifyInstaller = ".\Windows\install_spotify.bat" 

    if (Test-Path $spotifyInstaller) {
        Start-Process -FilePath $spotifyInstaller -Wait
        Write-Host "El instalador externo de Spotify se ha ejecutado correctamente."
    } else {
        Write-Host "No se encontró el instalador de Spotify en: $spotifyInstaller"
    }

    $officeFolder = "office"
    if (-Not (Test-Path $officeFolder)) {
        New-Item -Path $officeFolder -ItemType Directory
        Write-Host "Se ha creado la carpeta 'office'."
    }

    $officeInstaller = "$officeFolder\OfficeSetup.exe"
    $officeDownloadURL = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA"
    
    if (-Not (Test-Path $officeInstaller)) {
        Write-Host "Descargando Office..."
        Invoke-WebRequest -Uri $officeDownloadURL -OutFile $officeInstaller
        Write-Host "Office descargado a $officeInstaller"
    }

    if (Test-Path $officeInstaller) {
        Start-Process -FilePath $officeInstaller -Wait
        Write-Host "El instalador de Office se ha ejecutado."
    } else {
        Write-Host "No se encontró el instalador de Office en $officeInstaller"
    }

    Write-Host "Ejecutando activación de Windows con /Ohook y /HWID..."
    Invoke-RestMethod https://get.activated.win | Invoke-Expression /Ohook /HWID
    Write-Host "Activación completada."
}

# ============================
# Función: Prepare-Configuration
# ============================
# Prepara la configuración necesaria para las herramientas.
function Prepare-Configuration {
    # Configuración de Starship
    $rootFolder = "$env:USERPROFILE\Documents"
    $starshipFolder = "$rootFolder\starship"
    $starshipConfigPath = "$starshipFolder\starship.toml"
    $starshipCachePath = "$env:USERPROFILE\AppData\Local\Temp"

    # Crear carpetas necesarias
    if (-not (Test-Path $starshipCachePath)) {
        New-Item -ItemType Directory -Path $starshipCachePath | Out-Null
        Write-Host "La carpeta Temp ha sido creada en: $starshipCachePath"
    }

    Write-Host "La estructura de directorios para Starship ha sido configurada correctamente."
}

# ============================
# Función: Clean-Temp-Files
# ============================
# Limpia los archivos temporales utilizados durante el proceso.
function Clean-Temp-Files {
    $officeFolder = "office"

    if (Test-Path $officeFolder) {
        Write-Host "Limpiando la carpeta temporal: $officeFolder"
        Remove-Item -Path $officeFolder -Recurse -Force
        Write-Host "Carpeta temporal eliminada."
    } else {
        Write-Host "No se encontró una carpeta temporal para limpiar."
    }
}

# ============================
# Lógica principal del script
# ============================
# Requiere permisos de administrador
#Requires -RunAsAdministrator

Package-Installer
External-Installers
Prepare-Configuration
Clean-Temp-Files
