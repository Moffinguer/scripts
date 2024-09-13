
Function Set-WallPaper {
 
<#
 
    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop.
    https://www.joseespitia.com/2017/09/15/set-wallpaper-powershell-function/
    https://www.reddit.com/r/WindowsHelp/comments/18bde3i/desktop_background_turns_black_after_each_restart/
    
    .PARAMETER Image
    Provide the exact path to the image
 
    .PARAMETER Style
    Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
  
    .EXAMPLE
    Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
    Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
  
#>
 
param (
    [parameter(Mandatory=$True)]
    # Provide path to image
    [string]$Image,
    # Provide wallpaper style that you would like applied
    [parameter(Mandatory=$False)]
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
    [string]$Style
)
 
$WallpaperStyle = Switch ($Style) {
  
    "Fill" {"10"}
    "Fit" {"6"}
    "Stretch" {"2"}
    "Tile" {"0"}
    "Center" {"0"}
    "Span" {"22"}
  
}
 
If($Style -eq "Tile") {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
 
}
Else {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
 
}
 
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
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

## Lock Screen
function Set-LockscreenImage
{
<#
.SYNOPSIS
PowerShell script to set a local image as the lockscreen background.
https://github.com/nccgroup/Change-Lockscreen/blob/master/Change-Lockscreen.ps1

.PARAMETER ImagePath
Specify the full path to the image that you want to set as the lockscreen background.

.EXAMPLE
    PS C:\> . .\Set-LockscreenImage.ps1
    PS C:\> Set-LockscreenImage -ImagePath "C:\Images\lockscreen.jpg"
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
        "FiraCode" = "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
        "Iosevka" = "https://github.com/be5invis/Iosevka/releases/download/v31.5.0/PkgTTC-SGr-IosevkaTermSS05-31.5.0.zip"
        "Agave" = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Agave.zip"
        "JetBrainsMono" = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
    }

    # Define folder and file names
    $fontsFolder = "fonts"
    $files = @{
        "FiraCode" = "Fira_Code_v6.2.zip"
        "Iosevka" = "PkgTTC-SGr-IosevkaTermSS05-31.5.0.zip"
        "Agave" = "Agave.zip"
        "JetBrainsMono" = "JetBrainsMono.zip"
    }

    # Create 'fonts' folder if it doesn't exist
    if (-Not (Test-Path $fontsFolder)) {
        New-Item -Path $fontsFolder -ItemType Directory
    }

    # Download and extract ZIP files
    foreach ($key in $urls.Keys) {
        Write-Host "Downloading $key ZIP..."
        Invoke-WebRequest -Uri $urls[$key] -OutFile (Join-Path $fontsFolder $files[$key])
        
        Write-Host "Extracting $key ZIP..."
        Expand-Archive -Path (Join-Path $fontsFolder $files[$key]) -DestinationPath (Join-Path $fontsFolder $key)
    }

    # Install TTC fonts from Iosevka
    $iosevkaFolder = Join-Path $fontsFolder "Iosevka"
    Get-ChildItem -Path $iosevkaFolder -Filter *.ttc | ForEach-Object {
        $fontPath = $_.FullName
        Write-Host "Installing TTC font: $fontPath"
        Copy-Item $fontPath -Destination "$env:SystemRoot\Fonts\$(($_.Name))"
    }

    # Install TTF fonts from FiraCode
    $firaCodeFolder = Join-Path $fontsFolder "FiraCode" # Adjust if the folder structure is different
    $firaCodeTtfFolder = Join-Path $firaCodeFolder "ttf"

    Get-ChildItem -Path $firaCodeTtfFolder -Filter *.ttf | ForEach-Object {
        $fontPath = $_.FullName
        Write-Host "Installing TTF font: $fontPath"
        Copy-Item $fontPath -Destination "$env:SystemRoot\Fonts\$(($_.Name))"
    }

    # Install TTF fonts from Nerd Fonts
    foreach ($key in @("Agave", "JetBrainsMono")) {
        $nerdFontFolder = Join-Path $fontsFolder $key
        Get-ChildItem -Path $nerdFontFolder -Filter *.ttf | ForEach-Object {
            $fontPath = $_.FullName
            Write-Host "Installing TTF font: $fontPath"
            Copy-Item $fontPath -Destination "$env:SystemRoot\Fonts\$(($_.Name))"
        }
    }

    Write-Host "Font installation completed."
}

function Clean_temp_files {
    $fontsFolder = "fonts"

    # Remove 'fonts' folder and its contents
    if (Test-Path $fontsFolder) {
        Write-Host "Cleaning up temporary folder: $fontsFolder"
        Remove-Item -Path $fontsFolder -Recurse -Force
    } else {
        Write-Host "No temporary folder found to clean."
    }
}



#Requires -RunAsAdministrator

Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
Set-LockscreenImage -ImagePath "C:\Images\lockscreen.jpg"
Install-Fonts
Clean_temp_files