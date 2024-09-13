# Using Winget to install all the programs, If possible

function package_installer {
    function Install-PackageAndVerify {
        param (
            [string]$PackageName,
            [string]$Extras = "-i"
        )

        $installedPackage = winget list --id $PackageName
        if ($installedPackage) {
            Write-Host "The package $PackageName has been installed successfully."
        } else {
            Write-Host "Attempting to install $PackageName..."

            winget install --id $PackageName $Extras

            $installedPackage = winget list --id $PackageName

            if ($installedPackage) {
                Write-Host "The package $PackageName has been installed successfully."
            } else {
                Write-Host "The package $PackageName failed to install."
            }
        }
    }

    $jobs = @()
    
    ## Search for the override parameters for each package
    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "Neovim.Neovim.Nightly"
    }

    # $jobs += Start-Job -ScriptBlock {
    #     Install-PackageAndVerify -PackageName "Discord.Discord"
    # }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "Brave.Brave"
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "Mozilla.Firefox"
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "Microsoft.VisualStudioCode"
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "VideoLAN.VLC" # Substitutes for Windows Media Player and other video players
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "mcmilk.7zip-zstd"
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "c0re100.qBittorrent-Enhanced-Edition"
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "Valve.Steam"
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "Git.Git"
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "nomacs.nomacs" # Substitutes for Windows image viewer
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "JackieLiu.NotepadsApp" # Substitute for Windows notepad
    }

    $jobs += Start-Job -ScriptBlock {
        Install-PackageAndVerify -PackageName "Microsoft.PowerShell"
    }

    $jobs | ForEach-Object { 
        $job = $_
        Wait-Job $job
        Remove-Job $job
    }

    Write-Host "All installations have been completed."
}

# Function to install external software
function external_installers {
    $spotifyInstaller = "..\..\utils\Install_Spotify.bat"

    if (Test-Path $spotifyInstaller) {
        Start-Process -FilePath $spotifyInstaller -Wait
        Write-Host "The external Spotify installer has been executed successfully."
    } else {
        Write-Host "Spotify installer not found at: $spotifyInstaller"
    }

    $discordFolder = "discord"
    if (-Not (Test-Path $discordFolder)) {
        New-Item -Path $discordFolder -ItemType Directory
        Write-Host "'discord' folder created."
    } else {
        Write-Host "'discord' folder already exists."
    }

    $vencordInstaller = "$discordFolder\VencordInstaller.exe"
    $vencordDownloadURL = "https://github.com/Vencord/Installer/releases/latest/download/VencordInstaller.exe"

    if (-Not (Test-Path $vencordInstaller)) {
        Write-Host "Downloading Vencord Installer..."
        Invoke-WebRequest -Uri $vencordDownloadURL -OutFile $vencordInstaller
        Write-Host "Vencord Installer downloaded to $vencordInstaller"
    } else {
        Write-Host "Vencord Installer is already downloaded."
    }

    if (Test-Path $vencordInstaller) {
        Start-Process -FilePath $vencordInstaller -Wait
        Write-Host "The Vencord installer has been executed."
    } else {
        Write-Host "Vencord installer not found at $vencordInstaller"
    }

    $officeFolder = "office"
    if (-Not (Test-Path $officeFolder)) {
        New-Item -Path $officeFolder -ItemType Directory
        Write-Host "'office' folder created."
    } else {
        Write-Host "'office' folder already exists."
    }

    $officeInstaller = "$officeFolder\OfficeSetup.exe"
    $officeDownloadURL = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA"
    
    if (-Not (Test-Path $officeInstaller)) {
        Write-Host "Downloading Office..."
        Invoke-WebRequest -Uri $officeDownloadURL -OutFile $officeInstaller
        Write-Host "Office downloaded to $officeInstaller"
    } else {
        Write-Host "Office is already downloaded."
    }

    if (Test-Path $officeInstaller) {
        Start-Process -FilePath $officeInstaller -Wait
        Write-Host "The Office installer has been executed."
    } else {
        Write-Host "Office installer not found at $officeInstaller"
    }

    Write-Host "Running Windows activation with /Ohook and /HWID..."
    Invoke-RestMethod https://get.activated.win | Invoke-Expression /Ohook /HWID
    Write-Host "Activation completed."
}

function prepare_configuration {

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


function Clean_temp_files {
    $officeFolder = "office"
    $discordFolder = "discord"

    if (Test-Path $officeFolder) {
        Write-Host "Cleaning up temporary folder: $officeFolder"
        Remove-Item -Path $officeFolder -Recurse -Force
        Write-Host "Temporary folder removed."
    } else {
        Write-Host "No temporary folder found to clean."
    }

    if (Test-Path $discordFolder) {
        Write-Host "Cleaning up temporary folder: $discordFolder"
        Remove-Item -Path $discordFolder -Recurse -Force
        Write-Host "Temporary folder removed."
    } else {
        Write-Host "No temporary folder found to clean."
    }
}

#Requires -RunAsAdministrator

package_installer
external_installer
prepare_configuration
Clean_temp_files