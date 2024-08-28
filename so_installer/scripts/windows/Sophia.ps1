<#
	.SYNOPSIS
	Default preset file for "Sophia Script for Windows 11 (PowerShell 7)"

	Version: v6.6.9
	Date: 16.08.2024

	Copyright (c) 2014—2024 farag, Inestic & lowl1f3

	Thanks to all https://forum.ru-board.com members involved

	.DESCRIPTION
	Place the "#" char before function if you don't want to run it
	Remove the "#" char before function if you want to run it
	Every tweak in the preset file has its corresponding function to restore the default settings

	.EXAMPLE Run the whole script
	.\Sophia.ps1

	.EXAMPLE Run the script by specifying the module functions as an argument
	.\Sophia.ps1 -Functions "DiagTrackService -Disable", "DiagnosticDataLevel -Minimal", UninstallUWPApps

	.EXAMPLE Download and expand the latest Sophia Script version archive (without running) according which Windows and PowerShell versions it is run on
	irm script.sophi.app -useb | iex

	.NOTES
	Supported Windows 11 versions
	Version: 23H2+
	Editions: Home/Pro/Enterprise

	.NOTES
	To use the TAB completion for functions and their arguments dot source the Functions.ps1 script first:
		. .\Function.ps1 (with a dot at the beginning)
	Read more in the Functions.ps1 file

	.LINK GitHub
	https://github.com/farag2/Sophia-Script-for-Windows

	.LINK Telegram
	https://t.me/sophianews
	https://t.me/sophia_chat

	.LINK Discord
	https://discord.gg/sSryhaEv79

	.NOTES
	https://forum.ru-board.com/topic.cgi?forum=62&topic=30617#15
	https://habr.com/companies/skillfactory/articles/553800/
	https://forums.mydigitallife.net/threads/powershell-sophia-script-for-windows-10-windows-11-5-17-8-6-5-8-x64-2023.81675/
	https://www.reddit.com/r/PowerShell/comments/go2n5v/powershell_script_setup_windows_10/

	.LINK Authors
	https://github.com/farag2
	https://github.com/Inestic
	https://github.com/lowl1f3
#>

#Requires -RunAsAdministrator
#Requires -Version 7.3

[CmdletBinding()]
param
(
	[Parameter(Mandatory = $false)]
	[string[]]
	$Functions
)

Clear-Host

$Host.UI.RawUI.WindowTitle = "Sophia Script for Windows 11 v6.6.9 (PowerShell 7) | Made with $([System.Char]::ConvertFromUtf32(0x1F497)) of Windows | $([System.Char]0x00A9) farag, Inestic & lowl1f3, 2014$([System.Char]0x2013)2024"

Remove-Module -Name Sophia -Force -ErrorAction Ignore

Import-LocalizedData -BindingVariable Global:Localization -UICulture es-ES -BaseDirectory $PSScriptRoot\Localizations -FileName Sophia

# Check whether script is not running via PowerShell (x86)
try
{
	Import-Module -Name $PSScriptRoot\Manifest\Sophia.psd1 -PassThru -Force -ErrorAction Stop
}
catch [System.InvalidOperationException]
{
	Write-Warning -Message $Localization.PowerShellx86Warning

	Write-Verbose -Message "https://t.me/sophia_chat" -Verbose
	Write-Verbose -Message "https://discord.gg/sSryhaEv79" -Verbose

	exit
}


InitialActions -Warning

CreateRestorePoint

DiagTrackService -Enable
DiagnosticDataLevel -Minimal
ErrorReporting -Enable
FeedbackFrequency -Never
ScheduledTasks -Enable
SigninInfo -Enable
LanguageListAccess -Disable
AdvertisingID -Disable
WindowsWelcomeExperience -Show
WindowsTips -Enable #-Disable
SettingsSuggestedContent -Show #-Hide
AppsSilentInstalling -Disable
WhatsNewInWindows -Disable
TailoredExperiences -Disable
BingSearch -Disable
StartRecommendationsTips -Hide
StartAccountNotifications -Hide
ThisPC -Show
CheckBoxes -Enable
HiddenItems -Disable
FileExtensions -Show
MergeConflicts -Show
OpenFileExplorerTo -QuickAccess
FileExplorerCompactMode -Enable
OneDriveFileExplorerAd -Show
SnapAssist -Enable
FileTransferDialog -Detailed
RecycleBinDeleteConfirmation -Enable
QuickAccessRecentFiles -Hide
QuickAccessFrequentFolders -Hide
TaskbarAlignment -Left
TaskbarWidgets -Hide
TaskbarSearch -Hide
SearchHighlights -Show
CopilotButton -Hide
TaskViewButton -Hide
PreventTeamsInstallation -Enable
SecondsInSystemClock -Hide
TaskbarCombine -Always
UnpinTaskbarShortcuts -Shortcuts Edge, Store
TaskbarEndTask -Enable
ControlPanelView -Category
WindowsColorMode -Dark
AppColorMode -Dark
FirstLogonAnimation -Enable
JPEGWallpapersQuality -Max
ShortcutsSuffix -Disable
PrtScnSnippingTool -Enable
AppsLanguageSwitch -Enable
AeroShaking -Enable
Cursors -Light
FolderGroupBy -None
NavigationPaneExpand -Disable
OneDrive -Uninstall
StorageSense -Enable
StorageSenseFrequency -Month
StorageSenseTempFiles -Enable
Hibernation -Enable #-Disable #If I'm not using a Laptop
Win32LongPathLimit -Disable
BSoDStopError -Enable
AdminApprovalMode -Default
MappedDrivesAppElevatedAccess -Enable
DeliveryOptimization -Disable
WindowsManageDefaultPrinter -Disable
WindowsFeatures -Disable
WindowsCapabilities -Uninstall
UpdateMicrosoftProducts -Enable
RestartNotification -Show
RestartDeviceAfterUpdate -Disable
ActiveHours -Automatically
WindowsLatestUpdate -Disable
PowerPlan -Balanced #-High #If I'm not using a Laptop
NetworkAdaptersSavePower -Enable #-Disable #If I'm not using a Laptop
IPv6Component -PreferIPv4overIPv6
InputMethod -Default
Set-UserShellFolderLocation -Default
LatestInstalled.NET -Disable
WinPrtScrFolder -Default
RecommendedTroubleshooting -Automatically
FoldersLaunchSeparateProcess -Enable
ReservedStorage -Disable
F1HelpPage -Disable
# NumLock -Enable
# CapsLock -Disable
StickyShift -Disable
Autoplay -Disable
ThumbnailCacheRemoval -Disable
SaveRestartableApps -Enable
NetworkDiscovery -Enable
DefaultTerminalApp -WindowsTerminal
###############################################################################
# Export-Associations # Use when need to export all Windows associations
# Import-Associations # Use it on another computer
###############################################################################
InstallVCRedist
InstallDotNetRuntimes -Runtimes NET6x64, NET8x64
PreventEdgeShortcutCreation -Channels Stable, Beta, Dev, Canary
SATADrivesRemovableMedia -Default
RegistryBackup -Enable
Install-WSL
StartLayout -ShowMorePins
UninstallUWPApps -ForAllUsers
CortanaAutostart -Disable
TeamsAutostart -Disable
XboxGameBar -Enable
XboxGameTips -Disable
Set-AppGraphicsPerformance
GPUScheduling -Disable
CleanupTask -Register # -Delete # Solo si no quiero tener un limpiador de archivos 
SoftwareDistributionTask -Register # -Delete # Solo si no quiero tener un limpiador de archivos
TempTask -Register # -Delete # Solo si no quiero tener un limpiador de archivos
NetworkProtection -Enable
PUAppsDetection -Enable
DefenderSandbox -Enable
DismissMSAccount
DismissSmartScreenFilter
EventViewerCustomView -Enable
PowerShellModulesLogging -Enable
AppsSmartScreen -Disable
SaveZoneInformation -Disable
WindowsScriptHost -Enable
# WindowsSandbox -Enable
DNSoverHTTPS -Enable -PrimaryDNS 1.0.0.1 -SecondaryDNS 1.1.1.1
LocalSecurityAuthority -Enable
CABInstallContext -Show
MSIExtractContext -Show
EditWithClipchampContext -Hide
CompressedFolderNewContext -Hide
PrintCMDContext -Show
MultipleInvokeContext -Enable
UseStoreOpenWith -Hide
OpenWindowsTerminalContext -Show
OpenWindowsTerminalAdminContext -Enable

UpdateLGPEPolicies
PostActions
Errors