# ============================
# Función: SetWallpaper
# ============================
# Cambia el fondo de pantalla del escritorio del usuario actual.
function SetWallpaper {

    <#
    .SYNOPSIS
    Cambia el fondo de pantalla del usuario actual.

    .PARAMETER Image
    Ruta completa de la imagen que será usada como fondo de pantalla.

    .PARAMETER Style
    Estilo del fondo de pantalla: Fill, Fit, Stretch, Tile, Center o Span.

    .EXAMPLE
    SetWallpaper -Image "C:\Wallpaper\Default.jpg"
    SetWallpaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
    #>

    param (
        [parameter(Mandatory=$True)]
        [string]$Image,

        [parameter(Mandatory=$False)]
        [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
        [string]$Style
    )

    # Convertir el estilo a los valores esperados del registro
    $wallpaperStyle = Switch ($Style) {
        "Fill" {"10"}
        "Fit" {"6"}
        "Stretch" {"2"}
        "Tile" {"0"}
        "Center" {"0"}
        "Span" {"22"}
    }

    # Configurar los valores en el registro
    if ($Style -eq "Tile") {
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $wallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
    } else {
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $wallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
    }

    # Actualizar el fondo de pantalla
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Params
{
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@

    $SPI_SETDESKWALLPAPER = 0x0014
    $updateIniFile = 0x01
    $sendChangeEvent = 0x02
    $fWinIni = $updateIniFile -bor $sendChangeEvent

    [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}


# ============================
# Función: SetLockscreenImage
# ============================
# Cambia la imagen de la pantalla de bloqueo.
function SetLockscreenImage {
    <#
    .SYNOPSIS
    Cambia la imagen de la pantalla de bloqueo.

    .PARAMETER ImagePath
    Ruta completa de la imagen.

    .EXAMPLE
    SetLockscreenImage -ImagePath "C:\Images\lockscreen.jpg"
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String]$ImagePath     
    )

    # Load necessary types for handling the lockscreen image
    [Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime] | Out-Null
    Add-Type -AssemblyName System.Runtime.WindowsRuntime

    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | 
                      Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]

    Function Await($WinRtTask, $ResultType) {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }

    Function AwaitAction($WinRtAction) {
        $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | 
                   Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
        $netTask = $asTask.Invoke($null, @($WinRtAction))
        $netTask.Wait(-1) | Out-Null
    }

    try {
        # Load the image file from the specified path
        [Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
        $image = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($ImagePath)) ([Windows.Storage.StorageFile])

        # Set the lockscreen image
        AwaitAction ([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($image))
        write-output "Lockscreen image has been successfully set."
    }
    catch {
        write-output "An error occurred while setting the lockscreen image.
Possible solutions:
                      1 - Ensure the image path is correct.
                      2 - Try again with a different image."
    } 
}

function Install-Fonts {
    # Define URLs for the ZIP files
    $urls = @{
        "FiraCode"      = "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
        "Iosevka"       = "https://github.com/be5invis/Iosevka/releases/download/v32.3.0/PkgTTF-IosevkaTermSS05-32.3.0.zip"
        "Agave"         = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Agave.zip"
        "JetBrainsMono" = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"
    }

    $fontsFolder = "fonts"

    # Crear carpeta si no existe
    if (-not (Test-Path $fontsFolder)) {
        New-Item -Path $fontsFolder -ItemType Directory | Out-Null
    }

    foreach ($key in $urls.Keys) {
        $zipPath = Join-Path $fontsFolder "$key.zip"
        $destinationFolder = Join-Path $fontsFolder $key

        # Descargar fuente si no existe
        if (-not (Test-Path $zipPath)) {
            Write-Host "Descargando $key..."
            Invoke-WebRequest -Uri $urls[$key] -OutFile $zipPath
        }

        # Extraer fuente
        if (-not (Test-Path $destinationFolder)) {
            Expand-Archive -Path $zipPath -DestinationPath $destinationFolder
        }

        # Instalar las fuentes
        Get-ChildItem -Path $destinationFolder -Recurse -Filter *.ttf,*.ttc | ForEach-Object {
            Copy-Item $_.FullName -Destination "$env:SystemRoot\Fonts\$(($_.Name))"
        }
    }

    Write-Host "Instalación de fuentes completada."
}


# ============================
# Función: CleanTempFiles
# ============================
# Limpia carpetas temporales utilizadas durante el proceso.
function CleanTempFiles {
    param ()

    $foldersToClean = @("fonts", "wallpapers")

    foreach ($folder in $foldersToClean) {
        if (Test-Path $folder) {
            Remove-Item -Path $folder -Recurse -Force
        }
    }
}


# ============================
# Función: DownloadAndSaveImages
# ============================
# Descarga imágenes desde URLs específicas y las guarda en una ruta dada.
function DownloadAndSaveImages {
    param (
        [string]$url,
        [string]$destinationPath
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $destinationPath
        Write-Host "Descargado: $url a $destinationPath"
    } catch {
        Write-Host "Error al descargar $url: $_" -ForegroundColor Red
    }
}


# ============================
# Lógica principal del script
# ============================

# Crear carpeta para wallpapers
$wallpapersFolder = "wallpapers"
if (-not (Test-Path $wallpapersFolder)) {
    New-Item -ItemType Directory -Path $wallpapersFolder | Out-Null
}

# Descargar imágenes de fondo
DownloadAndSaveImages -url "https://github.com/Moffinguer/Wallpapers/raw/desktop/demonic%20skull.jpg" -destinationPath "$wallpapersFolder\Background.jpg"
DownloadAndSaveImages -url "https://github.com/Moffinguer/Wallpapers/raw/desktop/universe-programmer.jpg" -destinationPath "$wallpapersFolder\lockscreen.jpg"

# Aplicar fondo de pantalla y pantalla de bloqueo
SetWallpaper -Image "$wallpapersFolder\Background.jpg" -Style Fit
SetLockscreenImage -ImagePath "$wallpapersFolder\lockscreen.jpg"

# Instalar fuentes y limpiar archivos temporales
InstallFonts
CleanTempFiles


# To allow the execution of custom scripts after everything has ended
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser


echo "Activate Old Context Menu"
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve


$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$folderName = "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
$godModePath = Join-Path -Path $desktopPath -ChildPath $folderName

if (-not (Test-Path -Path $godModePath)) {
    New-Item -Path $godModePath -ItemType Directory
    Write-Host "Folder GodMode created in the user's desktop."
} else {
    Write-Host "Folder GodMode already exists in the user's desktop."
}
