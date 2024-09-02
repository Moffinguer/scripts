# Using Winget to install all the programs, If possible

function package_installer {
    ## Search for the override parameters for each package
    winget install --id Neovim.Neovim.Nightly -i
    Write-Host "The package Neovim.Neovim.Nightly has been installed successfully."

    winget install --id Discord.Discord -i
    Write-Host "The package Discord.Discord has been installed successfully."

    winget install --id Brave.Brave -i
    Write-Host "The package Brave.Brave has been installed successfully."

    winget install --id Mozilla.Firefox -i
    Write-Host "The package Mozilla.Firefox has been installed successfully."

    winget install --id Microsoft.VisualStudioCode -i
    Write-Host "The package Microsoft.VisualStudioCode has been installed successfully."

    winget install --id VideoLAN.VLC -i
    Write-Host "The package VideoLAN.VLC has been installed successfully."

    winget install --id mcmilk.7zip-zstd -i
    Write-Host "The package mcmilk.7zip-zstd has been installed successfully."

    winget install --id c0re100.qBittorrent-Enhanced-Edition -i
    Write-Host "The package c0re100.qBittorrent-Enhanced-Edition has been installed successfully."

    winget install --id Valve.Steam -i
    Write-Host "The package Valve.Steam has been installed successfully."

    winget install --id Git.Git -i
    Write-Host "The package Git.Git has been installed successfully."

    winget install --id nomacs.nomacs -i
    Write-Host "The package nomacs.nomacs has been installed successfully."

    winget install --id Starship.Starship -i
    Write-Host "The package Starship.Starship has been installed successfully."
}

# Function to install external software
function external_installers {
    Start-Process -FilePath "..\..\utils\Install_Spotify.bat" -Wait
    Write-Host "The external installer for Spotify has been executed successfully."
}

function configuration {

    ## TODO clone the dotfiles repo and move the folders acordingly

    # Starship, check the enviroment_variables.bat for correct routes
    $root_folder = "$env:USERPROFILE\Documents"
    $starship_folder = "$root_folder\starship"
    $starship_config_path = "$starship_folder\starship.toml"
    $starship_cache_path = "$env:USERPROFILE\AppData\Local\Temp"

    ## TODO BEGIN instead of creating the files and folders, move them from the cloned repo
    if (-not (Test-Path $starship_folder)) {
        New-Item -ItemType Directory -Path $starship_folder | Out-Null
        Write-Host "The folder 'starship' has been created at: $starship_folder"
    }

    if (-not (Test-Path $starship_config_path)) {
        New-Item -ItemType File -Path $starship_config_path | Out-Null
        Write-Host "The file 'starship.toml' has been created at: $starship_config_path"
    }
    ## TODO END
    if (-not (Test-Path $starship_cache_path)) {
        New-Item -ItemType Directory -Path $starship_cache_path | Out-Null
        Write-Host "The Temp folder has been created at: $starship_cache_path"
    }

    Write-Host "The directory structure for Starship has been set up successfully."
}

#Requires -RunAsAdministrator

package_installer
external_installer
configuration