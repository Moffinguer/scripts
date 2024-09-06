# Instructions for each SO

## Windows 11

### Dependencies

1. Check your Windows version:

    ```ps1
    Configuration >
                   System >
                           Information >
                                        WindowsSpecs >
                                                      Version
    ```

2. Check if the latest version is the same as the one over [here](https://github.com/farag2/Sophia-Script-for-Windows/releases/latest).

3. Download the correct version and unzip it.

4. Copy the __\bin__ folder into __\so_installer\scripts\windows\\__ and replace the folder on __Localizations__ with the one of your language. Here is an example using es-ES as example:
    ```ps1
    # Using Powershell
    Copy-Item -Path "scripts\bin" -Destination "scripts\so_installer\scripts\windows" -Recurse -Force
    
    Copy-Item -Path "scripts\Localizations\es-ES\Sophia.ps1" -Destination "scripts\so_installer\scripts\windows\Localizations\es-ES\Sophia.ps1" -Force

    ```
    ```cmd
    # Using CMD
    xcopy "scripts\bin" "scripts\so_installer\scripts\windows" /E /I /Y

    copy /Y "scripts\Localizations\es-ES\Sophia.ps1" "scripts\so_installer\scripts\windows\Localizations\es-ES\Sophia.ps1"

    ```
5. If there are new functions, check out for them and add them on _Sophia.ps1_
### Priviledges
You only need to run a Powershell Terminal as an Admin

### How to Run
Execute one of this scripts:
```bash
 # You need a bash terminal for this, install git and run it
  winget install -id Git.Git -i # With a Windows Terminal
  winget install --id Microsoft.PowerShell -i # Install Last version of Powershell
 cd .. && ./installer.sh # On a Bash Terminal
```
```ps1
.\windows.ps1
```
